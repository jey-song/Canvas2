//
//  Shaders.metal
//  Canvas2
//
//  Created by Adeola Uthman on 11/12/19.
//  Copyright © 2019 Adeola Uthman. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;


struct VertexIn {
    // The <x,y> position of the vertex.
    packed_float4 position;
    
    // The point size of the vertex.
    float point_size;
    
    // The color of the pixel.
    packed_float4 color;
};

struct VertexOut {
    float4 position [[position]];
    float point_size [[point_size]];
    float4 color;
};


// Most basic vertex.
//vertex float4 basic_vertex(const device packed_float4* vertex_array [[ buffer(0) ]], unsigned int vid [[ vertex_id ]]) {
//    return float4(vertex_array[vid]);
//}
//
//// Most basic fragment.
//fragment half4 basic_fragment() {
//    return half4(0.0); // <-- Black
//}

// Colored Vertex Shader.
vertex VertexOut colored_vertex(const device VertexIn* vertex_array [[ buffer(0) ]], unsigned int vid [[ vertex_id ]]) {
    
    // Get a reference to the vertex that is coming in.
    VertexIn vertexIn = vertex_array[vid];
    
    // Construct a vertex that will be returned after doing some transformations.
    VertexOut vertexOut;
    
    // Make the necessary transformations.
    vertexOut.position = float4(vertexIn.position);
    vertexOut.point_size = vertexIn.point_size;
    vertexOut.color = vertexIn.color;
    
    return vertexOut;
}

// Colored Fragment Shader.
fragment half4 colored_fragment(VertexOut interpolated [[stage_in]]) {
    return half4(interpolated.color[0], interpolated.color[1], interpolated.color[2], interpolated.color[3]);
}
