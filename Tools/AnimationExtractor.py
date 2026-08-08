import json

class FSpriteMeta:
    def __init__(self, data):
        self.spriteFilePath = data["spriteFilePath"]
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


path = input("Enter file path: ")
width = int(input("Enter Width: "))
startPoint = input("Enter the origin point: ").split(' ')
startX = int(startPoint[0])
startY = int(startPoint[1])
animationName = input("Enter Clip Name: ")
frameCount = int(input("Enter Number of Frames: "))

with open(path, 'r') as file:
    data = json.load(file)

spriteList = data['sprites']
for i in range(len(spriteList)-1, -1, -1):
    if animationName in spriteList[i]['spriteId']:
        del spriteList[i]

for i in range(frameCount):
    value = FSpriteData()
    value.spriteId = animationName + format(i, "02d")
    value.point = FVector(startX + i * width, startY).__dict__
    value.size = FVector(width, width).__dict__
    value.pivot = FVector(width / 2, width).__dict__
    spriteList.append(value.__dict__)

data['sprites'] = spriteList

with open(path, 'w') as file:
    json.dump(data, file, indent=4)