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
};

vertex Vertex main_vertex(const device Vertex* vertices [[ buffer(0) ]], unsigned int vid [[ vertex_id ]]) {
    Vertex output;
    
    output.position = vertices[vid].position;
    output.color = vertices[vid].color;
    
    return output;
};

fragment float4 main_fragment(Vertex vert [[stage_in]]) {
    return vert.color;
};
