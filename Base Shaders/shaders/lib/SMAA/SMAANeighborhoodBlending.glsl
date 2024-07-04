void SMAANeighborhoodBlending(out vec4 color, sampler2D colorTex, sampler2D velocityTex, sampler2D blendTex, bool useTAA, vec2 uv, ivec2 screenSize) {
	ivec2 texelCoord = ivec2(floor(uv * screenSize));

	vec4 a = vec4(texelFetchOffset(blendTex, texelCoord, 0, ivec2( 1,  0)).w, texelFetchOffset(blendTex, texelCoord, 0, ivec2( 0,  1)).y, texelFetch(blendTex, texelCoord, 0).zx);

	if (a.x + a.y + a.z + a.w >= 0.0000001) {
		vec2 blendingCoord = max(a.x, a.z) > max(a.y, a.w) ? vec2(uv.x + mix(a.x, -a.z, a.z / (a.x + a.z)) / screenSize.x, uv.y) : vec2(uv.x, uv.y + mix(a.y, -a.w, a.w / (a.y + a.w)) / screenSize.y);

		color.rgb = catmullRomTexture2D(colorTex, blendingCoord).rgb;
		color.a   = useTAA ? length(catmullRomTexture2D(velocityTex, blendingCoord).xy) : 1.0;
	} else {
		color.rgb = texelFetch(colorTex, texelCoord, 0).rgb;
		color.a   = useTAA ? length(texelFetch(velocityTex, texelCoord, 0).xy) : 1.0;
	}
}
