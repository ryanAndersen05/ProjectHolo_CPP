#version 150 compatibility

uniform sampler2D _texture;
uniform sampler2D _swapTexture;
uniform vec4 _color;

out vec4 fragColor;

void main()
{
    vec4 col = texture(_texture, gl_TexCoord[0].xy);
    vec4 swapCol = texture(_swapTexture, col.rg);
    vec4 final = mix(col, swapCol, swapCol.a);
    final *= _color;
    final.a = col.a;
    fragColor = final;
}