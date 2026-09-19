from PIL import Image
import os
from pathlib import Path
import math
import json

OccupationSize = 8

class FSpriteMeta:
    def __init__(self, data):
        self.spriteAsset = data["spriteAsset"]
        self.sprites = data["sprites"]
            

class FVector:
    def __init__(self, x, y):
        self.x = x
        self.y = y

class FSpriteData:
    def __init__(self):
        self.spriteId = ""
        self.point = {}
        self.size = {}
        self.pivot = {}

def resizeImage(previousImage, previousOccupiedTiles):
    newImage = Image.new("RGBA", (previousImage.width * 2, previousImage.height * 2))
    newImage.paste(previousImage, (0, 0))

    previousTileSize = int(math.sqrt(len(previousOccupiedTiles)))
    newOccupiedTiles = [False] * (len(previousOccupiedTiles) * 4)
    newTileSize = int(math.sqrt(len(newOccupiedTiles)))
    for i in range(previousTileSize):
        for j in range(previousTileSize):
            newOccupiedTiles[i + (j * newTileSize)] = previousOccupiedTiles[i + (j * previousTileSize)]
    previousImage.close()
    print ("Atlas Resized: W" + str(newImage.width) + " H" + str(newImage.height))
    return newImage, newOccupiedTiles

def validateSpace(occupiedSpace, startPoint, size):
    atlasWidth = int(math.sqrt(len(occupiedSpace)))
    x = startPoint[0]
    y = startPoint[1]
    for i in range(size[0]):
        for j in range(size[1]):
            if occupiedSpace[(x+i) + ((y+j) * atlasWidth)]:
                return False
    return True

def findValidCoordinates(occupiedSpace, imageSize):
    atlasWidth = int(math.sqrt(len(occupiedSpace)))
    width = int(imageSize[0] / OccupationSize)
    height = int(imageSize[1] / OccupationSize)
    for i in range(len(occupiedSpace)):
        if not occupiedSpace[i]:
            x = int(i % atlasWidth)
            y = int(i / atlasWidth)
            if x + width >= atlasWidth:
                continue
            if y + height >= atlasWidth:
                continue
            if not validateSpace(occupiedSpace, (x, y), (width, height)):
                continue
            return (x*OccupationSize, y*OccupationSize)
    return None

def markAsOccupied(occupiedSpace, startPoint, spriteSize):
    atlasWidth = int(math.sqrt(len(occupiedSpace)))
    x = int(startPoint[0] / OccupationSize)
    y = int(startPoint[1] / OccupationSize)
    width = int(math.ceil(spriteSize[0] / OccupationSize))
    height = int(math.ceil(spriteSize[1] / OccupationSize))

    for i in range(width):
        for j in range(height):
            occupiedSpace[(x+i) + ((y+j)*atlasWidth)] = True
            

def writeSpriteToAtlas(atlas_image, occupied_space, sprite_image):
    sprite_data_list = []
    sprite_width, sprite_height = sprite_image.size
    sprite_count = 1
    if sprite_width > sprite_height:
        sprite_count = int(sprite_width / sprite_height)
        sprite_width = sprite_height
    for i in range(sprite_count):
        coordinates = findValidCoordinates(occupied_space, (sprite_width, sprite_height))
        while coordinates is None:
            atlas_image, occupied_space = resizeImage(atlas_image, occupied_space)
            coordinates = findValidCoordinates(occupied_space, (sprite_width, sprite_height))
        x = coordinates[0]
        y = coordinates[1]
        atlas_image.paste(sprite_image.crop(((sprite_width * i), 0, (sprite_width * (i + 1)), sprite_height)), (x, y))
        sprite_data = FSpriteData()
        sprite_data.point = FVector(x, y).__dict__
        sprite_data.size = FVector(sprite_width, sprite_height).__dict__
        sprite_data.pivot = FVector(int(sprite_width / 2), sprite_height).__dict__
        sprite_data_list.append(sprite_data)
        markAsOccupied(occupied_space, coordinates, (sprite_width, sprite_height))
    return atlas_image, occupied_space, sprite_data_list

path = Path(input("Directory Of Atlas: "))
atlasName = path.parts[-1]
atlasJson = Path(os.path.join(path, atlasName + "Atlas.json"))
atlasName = Path(os.path.join(path, atlasName + "Atlas.png"))

allfiles = list(path.glob('*.png'))
atlasImage = Image.new("RGBA", (256,256))
occupiedTiles = [False] * int(atlasImage.width / OccupationSize) * int(atlasImage.height / OccupationSize)
spriteDataCollection = []

for sprite in allfiles:
    if atlasName.is_file() and atlasName.samefile(sprite):
        continue
    img = Image.open(sprite, 'r').convert("RGBA")
    print("Extracting: " + str(sprite))
    atlasImage, occupiedTiles, spriteData = writeSpriteToAtlas(atlasImage, occupiedTiles, img)
    img.close()
    for i in range(len(spriteData)):
        spriteData[i].spriteId = sprite.stem + format(i, "02d")
        spriteDataCollection.append(spriteData[i].__dict__)

atlasImage.save(atlasName)

data = {}
data['spriteAsset'] = str(path.parts[-1] + "_atlas_sprite")
data['sprites'] = spriteDataCollection

with open(atlasJson, 'w') as file:
    json.dump(data, file, indent=2)
