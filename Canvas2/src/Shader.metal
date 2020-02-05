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
    float2 position;
    float point_size [[point_size]];
    float4 color;
    float2 texture [[attribute(2)]];
};

struct VertexOut {
    float4 position [[position]];
    float point_size [[point_size]];
    float4 color;
    float2 texture [[attribute(2)]];
};



vertex VertexOut main_vertex(const device Vertex* vertices [[ buffer(0) ]], unsigned int vid [[ vertex_id ]]) {
    VertexOut output;
    
    output.position = float4(vertices[vid].position, 0, 1);
    output.point_size = vertices[vid].point_size;
    output.color = vertices[vid].color;
    output.texture = vertices[vid].texture;
    
    return output;
};

fragment half4 main_fragment(Vertex vert [[stage_in]]) {
    return half4(vert.color);
};


float2 transformPointCoord(float2 pointCoord, float a, float2 anchor) {
    float2 point20 = pointCoord - anchor;
    float x = point20.x * cos(a) - point20.y * sin(a);
    float y = point20.x * sin(a) + point20.y * cos(a);
    return float2(x, y) + anchor;
}
fragment half4 textured_fragment(Vertex vert [[stage_in]], sampler sampler2D,
                                 texture2d<float> texture [[texture(0)]],
                                 float2 pointCoord [[point_coord]]) {
    // If there's a texture, display it.
//    if(vert.texture[0] != -1 && vert.texture[1] != -1) {
//        float4 txr = texture.sample(sampler2D, pointCoord);
//        float4 clr = vert.color;
////        float4 blended = mix(txr, clr, 0.5);
//
//        if(length(pointCoord - float2(0.5)) > 0.5) {
//            txr.a = 0;
//        }
//        return half4(txr.r * clr.r, txr.g * clr.g, txr.b * clr.b, txr.a * clr.a);
////        return half4(blended.r, blended.g, blended.b, blended.a * vert.color.a);
//    }
//    // Otherwise, just the color.
//    else {
//        float4 clr = vert.color;
//        if(length(pointCoord - float2(0.5)) > 0.5) {
//            clr.a = 0;
//        }
//        return half4(clr);
//    }
    
    float2 text_coord = transformPointCoord(pointCoord, 0, float2(0.5));
    float4 color = float4(texture.sample(sampler2D, text_coord));
    return half4(float4(vert.color.rgb, color.a * vert.color.a));
//    return half4(vert.color.r, vert.color.g, vert.color.b, color.a * vert.color.a);
    
//    // If there's a texture, display that mixed with the current color.
//    if(vert.texture[0] != -1 && vert.texture[1] != -1) {
//        float4 txtr = texture.sample(sampler2D, float2(vert.texture[0], vert.texture[1]));
//        float4 clr = vert.color;
//        float4 blended = mix(txtr, clr, 0.5); // Blend exactly halfway between the texture and color.
//
//        // If the vertex has been erased, handle that here.
//        half4 ret = half4(blended);
//        ret.r -= vert.erase / 1.5;
//        ret.g -= vert.erase / 1.5;
//        ret.b -= vert.erase / 1.5;
//        ret.a -= vert.erase;
//
//        return ret;
//    }
//    // Otherwise, just show the brush color.
//    else {
//        float4 clr = vert.color;
//
//        // If the vertex has been erased, handle that here.
//        half4 ret = half4(clr);
//        ret.r -= vert.erase / 1.5;
//        ret.g -= vert.erase / 1.5;
//        ret.b -= vert.erase / 1.5;
//        ret.a -= vert.erase;
//
//        return ret;
//    }
}
