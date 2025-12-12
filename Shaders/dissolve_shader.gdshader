shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.1, 0.01) = 0.0; // 范围扩大到1.1，确保完全消失
uniform sampler2D noise_texture;

uniform vec4 edge_color : source_color = vec4(1.0, 0.5, 0.0, 1.0); // 默认为橙色
uniform float edge_width : hint_range(0.0, 0.1) = 0.05;

void fragment() {
    vec4 current_color = texture(TEXTURE, UV);
    float noise_value = texture(noise_texture, UV).r;

    // 如果噪声值小于进度减去边缘宽度，则完全消失
    if (noise_value < progress - edge_width) {
        discard;
    }
    // 如果噪声值在边缘范围内，则显示边缘颜色
    else if (noise_value < progress) {
        COLOR = edge_color;
    }
    // 否则，正常显示原始颜色
    else {
        COLOR = current_color;
    }

    // 确保精灵本身透明的部分不受影响
    COLOR.a *= current_color.a;
}