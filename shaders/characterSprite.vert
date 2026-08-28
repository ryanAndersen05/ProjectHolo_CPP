#version 150 core
uniform sampler2D _texture;
uniform sampler2D _swapTexture;

in vec2 s_vTexCoord;
out vec2 texCoord;
uniform mat4 sfmlModelViewProject;

void main()
{
    texCoord = s_vTexCoord;
}