//
//  Stripes.metal
//  MyApp
//
//  Created by Cong Le on 4/5/25.
//

/*
 Source: https://developer.apple.com/documentation/swiftui/creating-visual-effects-with-swiftui

Abstract:
A shader that applies stripes of multiple colors to a shape when using it as a
 SwiftUI `ShapeStyle`.
*/
#include <metal_stdlib>
#include <SwiftUI/SwiftUI.h>
using namespace metal;

[[ stitchable ]]
half4 Stripes(
    float2 position,
    float thickness,
    device const half4 *ptr,
    int count
) {
    int i = int(floor(position.y / thickness));

    // Clamp to 0 ..< count.
    i = ((i % count) + count) % count;

    return ptr[i];
}
