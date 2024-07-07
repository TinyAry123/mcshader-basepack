vec2 SMAASearchDiagonal1(sampler2D edgesTex, vec2 uv, vec2 direction, out vec2 e, ivec2 screenSize) {
	ivec2 texelCoord = ivec2(floor(uv * screenSize));
	float edgeWeight = 1.0;
	int searchStep   = -1;

	while (searchStep < 15 && edgeWeight > 0.9) {
		searchStep++;
		texelCoord += ivec2(direction);

		e = texelFetch(edgesTex, texelCoord, 0).xy;
		
		edgeWeight = 0.5 * (e.x + e.y);
	}

	return vec2(searchStep, edgeWeight);
}

vec2 SMAASearchDiagonal2(sampler2D edgesTex, vec2 uv, vec2 direction, out vec2 e, ivec2 screenSize) {
	float edgeWeight =  1.0;
	int searchStep   =  -1;
	uv.x             += 0.25 / screenSize.x;

	while (searchStep < 15 && edgeWeight > 0.9) {
		searchStep++;
		uv += direction / screenSize;

		e   =  texture2D(edgesTex, uv).xy;
		e.x *= abs(5.0 * e.x - 3.75);
		e   =  floor(e + 0.5);

		edgeWeight = 0.5 * (e.x + e.y);
	}

	return vec2(searchStep, edgeWeight);
}

vec2 SMAAAreaDiagonal(sampler2D areaTex, vec2 dist, vec2 e, float offset) {
	return texture2D(areaTex, (20.0 * e + dist + 0.5) * vec2(160.0, 560.0) + vec2(0.5, offset / 7.0)).xy;
}

vec2 SMAACalculateDiagonalWeights(sampler2D edgesTex, sampler2D areaTex, vec2 uv, vec2 e, vec4 subsampleIndices, ivec2 screenSize) {
	vec2 weights     = vec2(0.0);
	ivec2 texelCoord = ivec2(floor(uv * screenSize));
	vec4 d;
	vec2 end;

	if (e.x > 0.0) {
		d.xz =  SMAASearchDiagonal1(edgesTex, uv, vec2(-1.0,  1.0), end, screenSize);
		d.x  += float(end.y > 0.9);
	} else d.xz = vec2(0.0);

	d.yw = SMAASearchDiagonal1(edgesTex, uv, vec2( 1.0, -1.0), end, screenSize);

	if (d.x + d.y > 2.0) {
		vec4 coords = uv.xyxy + vec4(0.25 - d.x, d.x, d.y, -(0.25 + d.y)) / screenSize.xyxy;

		vec4 c =  vec4(texture2D(edgesTex, coords.xy + ivec2(-1,  0) / vec2(screenSize)).xy, texture2D(edgesTex, coords.zw + ivec2( 1,  0) / vec2(screenSize)).xy);
		c.xz   *= abs(5.0 * c.xz - 3.75);
		c.yxwz =  floor(c + 0.5);

		vec2 cc = (1.0 - step(0.9, d.zw)) * (2.0 * c.xz + c.yw);

		weights += SMAAAreaDiagonal(areaTex, d.xy, cc, subsampleIndices.z);
	}

	d.xz = SMAASearchDiagonal2(edgesTex, uv, vec2(-1.0, -1.0), end, screenSize);

	if (texelFetchOffset(edgesTex, texelCoord, 0, ivec2( 1,  0)).x > 0.0) {
		d.yw =  SMAASearchDiagonal2(edgesTex, uv, vec2( 1.0,  1.0), end, screenSize);
		d.y  += float(end.y > 0.9);
	} else d.yw = vec2(0.0);

	if (d.x + d.y > 2.0) {
		vec4 coords = uv.xyxy + vec4(-d.x, -d.x, d.y, d.y) / screenSize.xyxy;

		vec4 c = vec4(texture2D(edgesTex, coords.xy + ivec2(-1,  0) / vec2(screenSize)).y, texture2D(edgesTex, coords.xy + ivec2( 0, -1) / vec2(screenSize)).x, texture2D(edgesTex, coords.zw + ivec2( 1,  0) / vec2(screenSize)).yx);
		
		vec2 cc = (1.0 - step(0.9, d.zw)) * (2.0 * c.xz + c.yw);

		weights += SMAAAreaDiagonal(areaTex, d.xy, cc, subsampleIndices.w).yx;
	}

	return weights;
}

float SMAASearchLength(sampler2D searchTex, vec2 e, float offset) {
	return texelFetch(searchTex, ivec2(floor(vec2(32.0, -32.0) * e + vec2(66.0 * offset + 0.5, 32.5))), 0).x;
}

float SMAASearchXLeft(sampler2D edgesTex, sampler2D searchTex, vec2 uv, float end, ivec2 screenSize) {
	vec2 e = vec2(0.0, 1.0);

	while (uv.x > end && e.y > 0.8281 && e.x == 0.0) {
		e = texture2D(edgesTex, uv).xy;

		uv.x -= 2.0 / screenSize.x;
	}

	return uv.x + (3.25 - (255.0 / 127.0) * SMAASearchLength(searchTex, e, 0.0)) / screenSize.x;
}

float SMAASearchXRight(sampler2D edgesTex, sampler2D searchTex, vec2 uv, float end, ivec2 screenSize) {
	vec2 e = vec2(0.0, 1.0);

	while (uv.x < end && e.y > 0.8281 && e.x == 0.0) {
		e = texture2D(edgesTex, uv).xy;
		
		uv.x += 2.0 / screenSize.x;
	}
	
	return uv.x - (3.25 - (255.0 / 127.0) * SMAASearchLength(searchTex, e, 0.5)) / screenSize.x;
}

float SMAASearchYUp(sampler2D edgesTex, sampler2D searchTex, vec2 uv, float end, ivec2 screenSize) {
	vec2 e = vec2(1.0, 0.0);

	while (uv.y > end && e.x > 0.8281 && e.y == 0.0) {
		e = texture2D(edgesTex, uv).xy;

		uv.y -= 2.0 / screenSize.y;
	}

	return uv.y + (3.25 - (255.0 / 127.0) * SMAASearchLength(searchTex, e.yx, 0.0)) / screenSize.y;
}

float SMAASearchYDown(sampler2D edgesTex, sampler2D searchTex, vec2 uv, float end, ivec2 screenSize) {
	vec2 e = vec2(1.0, 0.0);

	while (uv.y < end && e.x > 0.8281 && e.y == 0.0) {
		e = texture2D(edgesTex, uv).xy;

		uv.y += 2.0 / screenSize.y;
	}

	return uv.y - (3.25 - (255.0 / 127.0) * SMAASearchLength(searchTex, e.yx, 0.5)) / screenSize.y;
}

vec2 SMAAArea(sampler2D areaTex, vec2 dist, float e1, float e2, float offset) {
	return texture2D(areaTex, (16.0 * floor(4.0 * vec2(e1, e2) + 0.5) + dist + 0.5) / vec2(160.0, 560.0) + vec2(0.0, offset / 7.0)).xy;
}

void SMAABlendingWeightCalculation(out vec4 weights, sampler2D edgesTex, sampler2D areaTex, sampler2D searchTex, bool useTAA, int frameMod2, vec2 uv, ivec2 screenSize) {
	ivec2 texelCoord       = ivec2(floor(uv * screenSize));
	ivec4 subsampleIndices = useTAA ? (bool(frameMod2) ? ivec4(2, 2, 2, 0) : ivec4(1, 1, 1, 0)) : ivec4(0);
	vec4 offsets[3];

	offsets[0] = uv.xyxy + vec4(-0.250, -0.125,  1.250, -0.125) / screenSize.xyxy;
	offsets[1] = uv.xyxy + vec4(-0.125, -0.250, -0.125,  1.250) / screenSize.xyxy;
	offsets[2] = vec4(offsets[0].xz, offsets[1].yw) + vec4(-64.0, 64.0, -64.0, 64.0) / screenSize.xxyy;

	vec2 e = texelFetch(edgesTex, texelCoord, 0).xy;

	if (e.y > 0.0) {
		weights.xy = SMAACalculateDiagonalWeights(edgesTex, areaTex, uv, e, vec4(subsampleIndices), screenSize);

		if (weights.x == -weights.y) {
			vec3 coords = vec3(SMAASearchXLeft(edgesTex, searchTex, offsets[0].xy, offsets[2].x, screenSize), offsets[1].y, SMAASearchXRight(edgesTex, searchTex, offsets[0].zw, offsets[2].y, screenSize));

			weights.xy = SMAAArea(areaTex, sqrt(abs(floor(screenSize.xx * (coords.xz - uv.xx) + 0.5))), texture2D(edgesTex, coords.xy).x, texture2D(edgesTex, coords.zy + ivec2( 1,  0) / vec2(screenSize)).x, float(subsampleIndices.y));
		} else e.x = 0.0;
	} else weights.xy = vec2(0.0);

	if (e.x > 0.0) {
		vec3 coords = vec3(offsets[0].x, SMAASearchYUp(edgesTex, searchTex, offsets[1].xy, offsets[2].z, screenSize), SMAASearchYDown(edgesTex, searchTex, offsets[1].zw, offsets[2].w, screenSize));

		weights.zw = SMAAArea(areaTex, sqrt(abs(floor(screenSize.yy * (coords.yz - uv.yy) + 0.5))), texture2D(edgesTex, coords.xy).y, texture2D(edgesTex, coords.xz + ivec2( 0,  1) / vec2(screenSize)).y, float(subsampleIndices.x));
	} else weights.zw = vec2(0.0);
}
