//
//  Shader.metal
//  Canvas2
//
//  Created by Adeola Uthman on 1/14/20.
//  Copyright © 2020 Adeola Uthman. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;


struct Vertex {
    float4 position [[position]];
    float4 color;
    float2 texture [[attribute(2)]];
    float erase;
};

vertex Vertex main_vertex(const device Vertex* vertices [[ buffer(0) ]], unsigned int vid [[ vertex_id ]]) {
    Vertex output;
    
    output.position = vertices[vid].position;
    output.color = vertices[vid].color;
    output.texture = vertices[vid].texture;
    output.erase = vertices[vid].erase;
    
    return output;
};

fragment half4 main_fragment(Vertex vert [[stage_in]]) {
    return half4(vert.color);
};

fragment half4 textured_fragment(Vertex vert [[stage_in]], sampler sampler2D, texture2d<float> texture [[texture(0)]]) {
    // If there's a texture, display that mixed with the current color.
    if(vert.texture[0] != -1 && vert.texture[1] != -1) {
        float4 txtr = texture.sample(sampler2D, float2(vert.texture[0], vert.texture[1]));
        float4 clr = vert.color;
        float4 blended = mix(txtr, clr, 0.5); // Blend exactly halfway between the texture and color.
        
        // If the vertex has been erased, handle that here.
        half4 ret = half4(blended);
        ret.r -= vert.erase / 1.5;
        ret.g -= vert.erase / 1.5;
        ret.b -= vert.erase / 1.5;
        ret.a -= vert.erase;
        
        return ret;
    }
    // Otherwise, just show the brush color.
    else {
        float4 clr = vert.color;
        
        // If the vertex has been erased, handle that here.
        half4 ret = half4(clr);
        ret.r -= vert.erase / 1.5;
        ret.g -= vert.erase / 1.5;
        ret.b -= vert.erase / 1.5;
        ret.a -= vert.erase;
        
        return ret;
    }
}
