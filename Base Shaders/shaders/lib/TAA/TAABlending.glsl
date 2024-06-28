/*
SMAA's optional temporal resolve method used. 
*/

vec4 TAABlending(out vec4 temporalColor, sampler2D currentColorTex, sampler2D previousColorTex, sampler2D velocityTex, vec2 uv, ivec2 screenSize) {
    ivec2 texelCoord = ivec2(floor(uv * screenSize));

    vec2 velocity = -texelFetch(velocityTex, texelCoord, 0).xy;

    vec4 current  = texelFetch(currentColorTex, texelCoord, 0);
    vec4 previous = catmullRomTexture2D(previousColorTex, uv + velocity);

    float delta  = abs(current.a - previous.a);
    float weight = 0.5 * clamp(1.0 - sqrt(delta) * 30.0, 0.0, 1.0);
    
    temporalColor = current;

    return mix(current, previous, weight);
}