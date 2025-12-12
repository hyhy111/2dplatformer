
shader_type canvas_item;

//在检查器中添加颜色选择器
uniform vec4 CAST_COLOR : source_color;

//获取底层屏幕纹理
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;

//在检查器中添加噪声资源（用于快速噪声）
uniform sampler2D fast_noise : repeat_enable;

//波浪移动的速度
uniform vec2 speed = vec2(0.03, 0.07);

//波浪的强度
uniform float wave_strength = 2;

//当编辑器更改时的缩放和缩放参数（从脚本设置）
uniform float scale_y;
uniform float y_zoom;

void vertex() {
    //上下移动
    VERTEX.y += sin(TIME) * 0.01;
}

void fragment() {
    //获取涟漪噪声
    vec2 uv = UV + speed * TIME;

    //从快速噪声中获取噪声
    vec2 noise = texture(fast_noise, uv).rg;

    //获取着色器所在对象的尺寸
    float uv_height = (SCREEN_PIXEL_SIZE.y / TEXTURE_PIXEL_SIZE.y);

    //计算反射来自哪里
    vec2 reflected_uv = vec2(SCREEN_UV.x, SCREEN_UV.y - (uv_height * UV.y * scale_y * y_zoom));

    //获取反射像素
    vec4 reflection = texture(SCREEN_TEXTURE, reflected_uv);
    //无波浪反射
    //COLOR = reflection + CAST_COLOR

    //计算涟漪的波浪
    vec4 waves = texture(SCREEN_TEXTURE, reflected_uv + noise * y_zoom * (wave_strength / 100.0));

    //应用波浪涟漪和选定的颜色
    COLOR =  waves + CAST_COLOR ;

}