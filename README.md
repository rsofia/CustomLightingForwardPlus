# CustomLightingForwardPlus
 How to implement custom lighting for Forward+ with ShaderGraph 

This repository expands on NedMakesGame's awesome "Creating Custom Lighting in Unity's Shader Graph with Universal Render Pipeline" tutorial. I've just made some tweaks to work with Additional Lights in Forward+. 

https://nedmakesgames.medium.com/creating-custom-lighting-in-unitys-shader-graph-with-universal-render-pipeline-5ad442c27276

#Notes: 
1. NedMakesGame's tutorial uses as a base the Unlit Universal RP shader graph, so to make the lighting work with Forward+, there needs to be one more multi_compile keyword added:  _FORWARD_PLUS.

2. Forward+ needs light loop macros LIGHT_LOOP_BEGIN and LIGHT_LOOP_END to iterate through the lights, and this loop requires a local variable of type InputData.

3. Because of how culling works in Forward+, it won't find additional lights when the camera is at a certain distance, so you'll need to make sure to check the clip space position for it to work. 

 #Resources

