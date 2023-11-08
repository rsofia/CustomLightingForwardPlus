# Custom Lighting in Forward+ with Shader Graph
 How to implement custom lighting for Forward+ with ShaderGraph 

This repository expands on NedMakesGame's awesome "[Creating Custom Lighting in Unity's Shader Graph with Universal Render Pipeline ](https://nedmakesgames.medium.com/creating-custom-lighting-in-unitys-shader-graph-with-universal-render-pipeline-5ad442c27276)" tutorial. I've just made some tweaks to work with Additional Lights in Forward+. 


## Notes: 
1. NedMakesGame's tutorial uses as a base the Unlit Universal RP shader graph, so to make the lighting work with Forward+, there needs to be one more multi_compile keyword added:  _FORWARD_PLUS.

![Screenshot of the keyword in _FORWARD_PLUS SG_TestLighting.shadergraph ](https://github.com/rsofia/CustomLightingForwardPlus/blob/main/Images/Keyword.PNG)

2. Forward+ needs light loop macros LIGHT_LOOP_BEGIN and LIGHT_LOOP_END to iterate through the lights, and this loop requires a local variable of type InputData.

```
        #ifdef _FORWARD_PLUS
            uint lightsCount = GetAdditionalLightsCount();
            InputData inputData = (InputData)0;
            inputData.positionWS = d.positionWS;
            inputData.normalWS = d.normalWS;
            inputData.viewDirectionWS = d.viewDirectionWS;
            inputData.shadowCoord = d.shadowCoord;

            float4 screenPos = float4(d.positionCS.x, (_ScaledScreenParams.y - d.positionCS.y), 0, 0);
            inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(screenPos);

            LIGHT_LOOP_BEGIN(lightsCount)
                 Light light = GetAdditionalLight(lightIndex, d.positionWS);
                 lightColor += CustomLightHandling(d, light);
            LIGHT_LOOP_END
        #endif  //end _FORWARD_PLUS
```

3. Because of how culling works in Forward+, it won't find additional lights when the camera is at a certain distance, so you'll need to make sure to check the clip space position for it to work. 

![Screenshot of how to fetch the clip position with theScreenPosition node and the Mode set to Pixel](https://github.com/rsofia/CustomLightingForwardPlus/blob/main/Images/ClipPos.PNG)

## Comparison
The following screenshot shows a comparison between the Universal RP Lit shader and the custom ShaderGraph shader, and both show the result with 3 Point Lights. 
![Comparison GIF between additional lights in Lit and the custom ShaderGraph shader](https://github.com/rsofia/CustomLightingForwardPlus/blob/main/Images/ScreenSpace_ForwardPlus.gif)

## Resources

