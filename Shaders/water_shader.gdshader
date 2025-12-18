shader_type canvas_item;

uniform vec4 CAST_COLOR : source_color;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest; // 必须保留 filter_nearest
uniform sampler2D fast_noise : repeat_enable;
uniform vec2 speed = vec2(0.03, 0.07);
uniform float wave_strength = 2;
uniform float scale_y;
uniform float y_zoom;

void vertex() {
    VERTEX.y += sin(TIME) * 0.01;
}

void fragment() {
    vec2 uv = UV + speed * TIME;
    vec2 noise = texture(fast_noise, uv).rg;
    float uv_height = (SCREEN_PIXEL_SIZE.y / TEXTURE_PIXEL_SIZE.y);

    // 计算反射坐标
    vec2 reflected_uv = vec2(SCREEN_UV.x, SCREEN_UV.y - (uv_height * UV.y * scale_y * y_zoom));
    
    // 计算最终带波浪的坐标
    vec2 final_uv = reflected_uv + noise * y_zoom * (wave_strength / 100.0);

    // 【修复1】从 SCREEN_TEXTURE 获取颜色
    vec4 waves = texture(SCREEN_TEXTURE, final_uv);

    // 【修复2】不要用加法 (+)，改用 mix (混合)
    // 加法会导致颜色爆表变白。这里假设 CAST_COLOR 是你想给水染的颜色
    // 0.3 是混合强度，你可以根据需要调整
    vec4 final_color = mix(waves, CAST_COLOR, CAST_COLOR.a * 0.5); 

    // 【修复3：核心】消除顶部灰线
    // 如果 UV.y 非常靠近顶部（0.0 到 0.05），强制把透明度降为 0
    // smoothstep 会在 0.0 到 0.05 之间产生一个平滑的过渡（0 -> 1）
    // 这样水面和地面的接缝处会有一点点渐变透明，完美掩盖那条灰线
    float edge_mask = smoothstep(0.0, 0.05, UV.y); 
    
    // 应用颜色
    COLOR = final_color;
    // 应用边缘遮罩
    COLOR.a *= edge_mask;
	
}