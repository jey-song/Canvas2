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
};

struct VertexOut {
    float4 position [[position]];
    float point_size [[point_size]];
    float4 color;
};



vertex VertexOut main_vertex(const device Vertex* vertices [[ buffer(0) ]], unsigned int vid [[ vertex_id ]]) {
    VertexOut output;
    
    output.position = float4(vertices[vid].position, 0, 1);
    output.point_size = vertices[vid].point_size;
    output.color = vertices[vid].color;
    
    return output;
};

fragment half4 main_fragment(Vertex vert [[stage_in]]) {
    return half4(vert.color);
};


float2 transformPointCoord(float2 pointCoord, float2 anchor) {
    float2 point = pointCoord - anchor;
    float x = point.x * cos(0.0) - point.y * sin(0.0);
    float y = point.x * sin(0.0) + point.y * cos(0.0);
    return float2(x, y) + anchor;
}
fragment half4 textured_fragment(Vertex vert [[stage_in]], sampler sampler2D,
                                 texture2d<float> texture [[texture(0)]],
                                 float2 pointCoord [[point_coord]]) {
    if(vert.point_size == 0) {
        return half4(0);
    }
    
    float2 text_coord = transformPointCoord(pointCoord, float2(0.5));
    float4 color = float4(texture.sample(sampler2D, text_coord));
    float4 ret = float4(vert.color.rgb, color.a * vert.color.a * vert.color.a);
    
    return half4(ret);
}
