void CAS(inout vec3 color, sampler2D colorTex, vec2 uv, ivec2 screenSize) {
	ivec2 texelCoord = ivec2(floor(uv * screenSize));

	vec3 d = texelFetchOffset(colorTex, texelCoord, 0, ivec2(-1,  0)).rgb;
	vec3 f = texelFetchOffset(colorTex, texelCoord, 0, ivec2( 1,  0)).rgb;
	vec3 b = texelFetchOffset(colorTex, texelCoord, 0, ivec2( 0, -1)).rgb;
	vec3 h = texelFetchOffset(colorTex, texelCoord, 0, ivec2( 0,  1)).rgb;

	vec3 eLin = color * color * color;
	vec3 dLin = d * d * d;
	vec3 fLin = f * f * f;
	vec3 bLin = b * b * b;
	vec3 hLin = h * h * h;
	vec3 aLin = pow(texelFetchOffset(colorTex, texelCoord, 0, ivec2(-1, -1)).rgb, ivec3(3));
	vec3 gLin = pow(texelFetchOffset(colorTex, texelCoord, 0, ivec2(-1,  1)).rgb, ivec3(3));
	vec3 iLin = pow(texelFetchOffset(colorTex, texelCoord, 0, ivec2( 1,  1)).rgb, ivec3(3));
	vec3 cLin = pow(texelFetchOffset(colorTex, texelCoord, 0, ivec2( 1, -1)).rgb, ivec3(3));

	float minLuma =  min(min(min(dLin.r, eLin.r), min(fLin.r, bLin.r)), hLin.r);
	float maxLuma =  max(max(max(dLin.r, eLin.r), max(fLin.r, bLin.r)), hLin.r);
	minLuma       += min(minLuma, min(min(aLin.r, cLin.r), min(gLin.r, iLin.r)));
	maxLuma       += max(maxLuma, max(max(aLin.r, cLin.r), max(gLin.r, iLin.r)));

	float weightLuma = -clamp(sqrt(min(minLuma, 2.0 - maxLuma) / maxLuma) / 8.0, 0.0, 0.125);

	color.r = clamp(((b.r + d.r + f.r + h.r) * weightLuma + color.r) / (4.0 * weightLuma + 1.0), 0.0, 1.0);

	if (color.g < 0.0) {
		color.g = -color.g;

		b.g = -min(b.g, 0.0);
		d.g = -min(d.g, 0.0);
		f.g = -min(f.g, 0.0);
		h.g = -min(h.g, 0.0);

		eLin.g = -min(eLin.g, 0.0);
		dLin.g = -min(dLin.g, 0.0);
		fLin.g = -min(fLin.g, 0.0);
		bLin.g = -min(bLin.g, 0.0);
		hLin.g = -min(hLin.g, 0.0);
		aLin.g = -min(aLin.g, 0.0);
		gLin.g = -min(gLin.g, 0.0);
		iLin.g = -min(iLin.g, 0.0);
		cLin.g = -min(cLin.g, 0.0);

		float minColorA =  min(min(min(dLin.g, eLin.g), min(fLin.g, bLin.g)), hLin.g);
		float maxColorA =  max(max(max(dLin.g, eLin.g), max(fLin.g, bLin.g)), hLin.g);
		minColorA       += min(minColorA, min(min(aLin.g, cLin.g), min(gLin.g, iLin.g)));
		maxColorA       += max(maxColorA, max(max(aLin.g, cLin.g), max(gLin.g, iLin.g)));

		float weightColorA = -clamp(sqrt(min(minColorA, 2.0 - maxColorA) / maxColorA) / 8.0, 0.0, 0.125);

		color.g = clamp(-(((b.g + d.g + f.g + h.g) * weightColorA + color.g) / (4.0 * weightColorA + 1.0)), -1.0, 0.0);
	} else {
		b.g = max(b.g, 0.0);
		d.g = max(d.g, 0.0);
		f.g = max(f.g, 0.0);
		h.g = max(h.g, 0.0);

		eLin.g = max(eLin.g, 0.0);
		dLin.g = max(dLin.g, 0.0);
		fLin.g = max(fLin.g, 0.0);
		bLin.g = max(bLin.g, 0.0);
		hLin.g = max(hLin.g, 0.0);
		aLin.g = max(aLin.g, 0.0);
		gLin.g = max(gLin.g, 0.0);
		iLin.g = max(iLin.g, 0.0);
		cLin.g = max(cLin.g, 0.0);

		float minColorA =  min(min(min(dLin.g, eLin.g), min(fLin.g, bLin.g)), hLin.g);
		float maxColorA =  max(max(max(dLin.g, eLin.g), max(fLin.g, bLin.g)), hLin.g);
		minColorA       += min(minColorA, min(min(aLin.g, cLin.g), min(gLin.g, iLin.g)));
		maxColorA       += max(maxColorA, max(max(aLin.g, cLin.g), max(gLin.g, iLin.g)));

		float weightColorA = -clamp(sqrt(min(minColorA, 2.0 - maxColorA) / maxColorA) / 8.0, 0.0, 0.125);

		color.g = clamp(((b.g + d.g + f.g + h.g) * weightColorA + color.g) / (4.0 * weightColorA + 1.0), 0.0, 1.0);
	}

	if (color.b < 0.0) {
		color.b = -color.b;

		b.b = -min(b.b, 0.0);
		d.b = -min(d.b, 0.0);
		f.b = -min(f.b, 0.0);
		h.b = -min(h.b, 0.0);

		eLin.b = -min(eLin.b, 0.0);
		dLin.b = -min(dLin.b, 0.0);
		fLin.b = -min(fLin.b, 0.0);
		bLin.b = -min(bLin.b, 0.0);
		hLin.b = -min(hLin.b, 0.0);
		aLin.b = -min(aLin.b, 0.0);
		gLin.b = -min(gLin.b, 0.0);
		iLin.b = -min(iLin.b, 0.0);
		cLin.b = -min(cLin.b, 0.0);

		float minColorB =  min(min(min(dLin.b, eLin.b), min(fLin.b, bLin.b)), hLin.b);
		float maxColorB =  max(max(max(dLin.b, eLin.b), max(fLin.b, bLin.b)), hLin.b);
		minColorB       += min(minColorB, min(min(aLin.b, cLin.b), min(gLin.b, iLin.b)));
		maxColorB       += max(maxColorB, max(max(aLin.b, cLin.b), max(gLin.b, iLin.b)));

		float weightColorB = -clamp(sqrt(min(minColorB, 2.0 - maxColorB) / maxColorB) / 8.0, 0.0, 0.125);

		color.b = clamp(-(((b.b + d.b + f.b + h.b) * weightColorB + color.b) / (4.0 * weightColorB + 1.0)), -1.0, 0.0);
	} else {
		b.b = max(b.b, 0.0);
		d.b = max(d.b, 0.0);
		f.b = max(f.b, 0.0);
		h.b = max(h.b, 0.0);

		eLin.b = max(eLin.b, 0.0);
		dLin.b = max(dLin.b, 0.0);
		fLin.b = max(fLin.b, 0.0);
		bLin.b = max(bLin.b, 0.0);
		hLin.b = max(hLin.b, 0.0);
		aLin.b = max(aLin.b, 0.0);
		gLin.b = max(gLin.b, 0.0);
		iLin.b = max(iLin.b, 0.0);
		cLin.b = max(cLin.b, 0.0);

		float minColorB =  min(min(min(dLin.b, eLin.b), min(fLin.b, bLin.b)), hLin.b);
		float maxColorB =  max(max(max(dLin.b, eLin.b), max(fLin.b, bLin.b)), hLin.b);
		minColorB       += min(minColorB, min(min(aLin.b, cLin.b), min(gLin.b, iLin.b)));
		maxColorB       += max(maxColorB, max(max(aLin.b, cLin.b), max(gLin.b, iLin.b)));

		float weightColorB = -clamp(sqrt(min(minColorB, 2.0 - maxColorB) / maxColorB) / 8.0, 0.0, 0.125);

		color.b = clamp(((b.b + d.b + f.b + h.b) * weightColorB + color.b) / (4.0 * weightColorB + 1.0), 0.0, 1.0);
	}
}
