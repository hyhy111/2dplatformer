shader_type canvas_item;

// --- 原有溶解参数 ---
uniform float progress : hint_range(0.0, 1.1, 0.01) = 0.0;
uniform sampler2D noise_texture;
uniform vec4 edge_color : source_color = vec4(1.0, 0.5, 0.0, 1.0);
uniform float edge_width : hint_range(0.0, 0.1) = 0.05;

// 这里默认设为洋红色 (R:1, G:0, B:1)，你可以用吸管吸你图里的特殊色
uniform vec4 magic_color : source_color = vec4(1.0, 0.0, 1.0, 1.0);
// 替换后的颜色（你想让它最后显示成什么颜色？比如白色）
uniform vec4 replace_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
// 发光强度
uniform float glow_intensity = 4.0;
// 容差（防止压缩导致的颜色不纯，稍微给点容错）
uniform float tolerance : hint_range(0.0, 0.1) = 0.01;

void fragment() {
    vec4 current_color = texture(TEXTURE, UV);
    float noise_value = texture(noise_texture, UV).r;

    // 1. 溶解逻辑
    if (noise_value < progress - edge_width) {
        discard;
    }
    else if (noise_value < progress) {
        COLOR = edge_color;
    }
    // 2. magic_color 替换逻辑
    else {
        // 计算当前像素颜色和 magic_color 的距离
        float dist = distance(current_color.rgb, magic_color.rgb);

        // 如果是magic_color
        if (dist <= tolerance && current_color.a > 0.01) {
            // 把它替换成目标颜色，并乘上强度让它发光
            COLOR.rgb = replace_color.rgb * glow_intensity;
            COLOR.a = current_color.a; // 保持原有透明度
        } else {
            // 不是 magic_color，保持原样
            COLOR = current_color;
        }
    }

    COLOR.a *= current_color.a;
}