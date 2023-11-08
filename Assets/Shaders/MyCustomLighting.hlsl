#ifndef MYCUSTOM_LIGHTING_INCLUDED
#define MYCUSTOM_LIGHTING_INCLUDED

#if !defined(SHADERGRAPH_PREVIEW)
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#endif

#ifndef SHADERGRAPH_PREVIEW
    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
    #if (SHADERPASS != SHADERPASS_FORWARD)
        #undef REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR
    #endif
#endif

struct CustomLightingData {
    // Position and orientation
    float3 positionWS;
    float3 normalWS;
    float3 viewDirectionWS;
    float4 shadowCoord;
    float3 positionCS;

    // Surface attributes
    float3 albedo;
    float smoothness;
};

float GetSmoothnessPower(float rawSmoothness) {
    return exp2(10 * rawSmoothness + 1);
}

#ifndef SHADERGRAPH_PREVIEW
float3 CustomLightHandling(CustomLightingData d, Light light) {

    float3 radiance = light.color * (light.distanceAttenuation * light.shadowAttenuation);

    float diffuse = saturate(dot(d.normalWS, light.direction));
    float specularDot = saturate(dot(d.normalWS, normalize(light.direction + d.viewDirectionWS)));
    float specular = pow(specularDot, GetSmoothnessPower(d.smoothness)) * diffuse;

    float3 color = d.albedo * radiance * (diffuse + specular);

    return color;
}
#endif

void AdditionalLights(CustomLightingData d, inout float3 lightColor)
{
#ifndef SHADERGRAPH_PREVIEW
#ifdef _ADDITIONAL_LIGHTS
    // Additional lights as in the tutorial
    uint numAdditionalLights = GetAdditionalLightsCount();
    for (uint lightI = 0; lightI < numAdditionalLights; lightI++) {
        Light light = GetAdditionalLight(lightI, d.positionWS, 1);
        lightColor += CustomLightHandling(d, light);
    }

#ifdef _FORWARD_PLUS
    uint lightsCount = GetAdditionalLightsCount();
    InputData inputData = (InputData)0;
    inputData.positionWS = d.positionWS;
    inputData.normalWS = d.normalWS;
    inputData.viewDirectionWS = d.viewDirectionWS;
    inputData.shadowCoord = d.shadowCoord;

    //Fix lights disappearing 
    float4 screenPos = float4(d.positionCS.x, (_ScaledScreenParams.y - d.positionCS.y), 0, 0);
    inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(screenPos);

    LIGHT_LOOP_BEGIN(lightsCount)
         Light light = GetAdditionalLight(lightIndex, d.positionWS);
         lightColor += CustomLightHandling(d, light);
    LIGHT_LOOP_END
#endif

#endif
#endif
}

float3 CalculateCustomLighting(CustomLightingData d) {
    #ifdef SHADERGRAPH_PREVIEW
    // In preview, estimate diffuse + specular
    float3 lightDir = float3(0.5, 0.5, 0);
    float intensity = saturate(dot(d.normalWS, lightDir)) +
        pow(saturate(dot(d.normalWS, normalize(d.viewDirectionWS + lightDir))), GetSmoothnessPower(d.smoothness));
    return d.albedo * intensity;
    #else
    // Get the main light. Located in URP/ShaderLibrary/Lighting.hlsl
    Light mainLight = GetMainLight(d.shadowCoord, d.positionWS, 1);

    float3 color = 0;
    // Shade the main light
    color += CustomLightHandling(d, mainLight);

     //Additional lights
     AdditionalLights(d, color);
   
    
    return color;
    #endif
   
}


void CalculateCustomLighting_float(float3 ClipPos,float3 Position, float3 Normal, float3 ViewDirection,
    float3 Albedo, float Smoothness,
    out float3 Color) {

    CustomLightingData d;
    d.normalWS = Normal;
    d.viewDirectionWS = ViewDirection;
    d.albedo = Albedo;
    d.smoothness = Smoothness;
    d.positionWS = Position;
    d.positionCS = ClipPos;  //Needed so the lights do not stop rendering when the Camera is at a certain distance

    #ifdef SHADERGRAPH_PREVIEW
        // In preview, there's no shadows or bakedGI
         d.shadowCoord = 0;
    #else
 
        d.positionCS = ClipPos;

        #if SHADOWS_SCREEN
            d.shadowCoord = ComputeScreenPos(positionCS);
        #else
            d.shadowCoord = TransformWorldToShadowCoord(Position);
        #endif

    #endif
 
    
    Color = CalculateCustomLighting(d);
}


#endif