/*
We need to be able to calculate velocity beforehand and write it to a texture 
for later sampling as velocity values will also be anti-aliased and packed into 
the alpha color channel at the final stage of the SMAA 1x pipeline, prior to being 
used for TAA blending in the SMAA T2x pipeline. 
*/

vec2 TAAReprojection(vec3 position) {
	position = position * 2.0 - 1.0;

	vec4 viewPositionPrevious = gbufferProjectionInverse * vec4(position, 1.0);
	viewPositionPrevious      = gbufferModelViewInverse * (viewPositionPrevious / viewPositionPrevious.w);

	vec4 previousPosition = gbufferPreviousProjection * (gbufferPreviousModelView * vec4(viewPositionPrevious.xyz + float(position.z > 0.56) * (cameraPosition - previousCameraPosition), viewPositionPrevious.w));
	
    return previousPosition.xy / previousPosition.w * 0.5 + 0.5;
}

vec2 TAACalculateVelocity(sampler2D depthTex, vec2 uv, ivec2 screenSize) {
    return uv - TAAReprojection(vec3(uv, texelFetch(depthTex, ivec2(floor(uv * screenSize)), 0).r));
}
