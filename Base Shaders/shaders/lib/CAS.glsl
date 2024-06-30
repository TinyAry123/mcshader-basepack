void CAS(inout vec3 color, sampler2D colorTex, vec2 uv, ivec2 screenSize) { // AMD FidelityFX Contrast Adaptive Sharpening (CAS), adapted for OkLab color space. 
	ivec2 texelCoord = ivec2(floor(uv * screenSize));
	
	vec3 d = texelFetch(colorTex, texelCoord + ivec2(-1,  0), 0).rgb;
	vec3 f = texelFetch(colorTex, texelCoord + ivec2( 1,  0), 0).rgb;
	vec3 b = texelFetch(colorTex, texelCoord + ivec2( 0, -1), 0).rgb;
	vec3 h = texelFetch(colorTex, texelCoord + ivec2( 0,  1), 0).rgb;

	float eLuma = OKLAB_TO_LINLUMA(color); // Simplify weight calculation to use linearised OkLab perceptual luminosity instead of all three linear sRGB channels. 
	float dLuma = OKLAB_TO_LINLUMA(d);
	float fLuma = OKLAB_TO_LINLUMA(f);
	float bLuma = OKLAB_TO_LINLUMA(b);
	float hLuma = OKLAB_TO_LINLUMA(h);
	float aLuma = OKLAB_TO_LINLUMA(texelFetch(colorTex, texelCoord + ivec2(-1, -1), 0).rgb);
	float gLuma = OKLAB_TO_LINLUMA(texelFetch(colorTex, texelCoord + ivec2(-1,  1), 0).rgb);
	float iLuma = OKLAB_TO_LINLUMA(texelFetch(colorTex, texelCoord + ivec2( 1,  1), 0).rgb);
	float cLuma = OKLAB_TO_LINLUMA(texelFetch(colorTex, texelCoord + ivec2( 1, -1), 0).rgb);

	float minLuma =  min(min(min(dLuma, eLuma), min(fLuma, bLuma)), hLuma);
	float maxLuma =  max(max(max(dLuma, eLuma), max(fLuma, bLuma)), hLuma);
	minLuma       += min(minLuma, min(min(aLuma, cLuma), min(gLuma, iLuma)));
	maxLuma       += max(maxLuma, max(max(aLuma, cLuma), max(gLuma, iLuma)));

	float weight = -(sqrt(clamp(min(minLuma, 2.0 - maxLuma) / maxLuma, 0.0, 1.0)) / 6.5); // Precalculated 50% contrast adaption as recommended by AMD. 

	color = clamp(((b + d + f + h) * weight + color) / (4.0 * weight + 1.0), vec3(0.0, -1.0, -1.0), vec3(1.0, 1.0, 1.0)); // OkLab color space is in range [0, 1], [-1, 1], [-1, 1]. 
}
