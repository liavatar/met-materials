import MetalKit

struct Quad {
//  var vertices: [Float] = [
//    -1,  1,  0,    // triangle 1
//     1, -1,  0,
//    -1, -1,  0,
//    -1,  1,  0,    // triangle 2
//     1,  1,  0,
//     1, -1,  0
//  ]
  
  // MARK: - 2 using index
  var vertices: [Float] = [
    -1,  1,  0,
     1,  1,  0,
    -1, -1,  0,
     1, -1,  0
  ]
  var indices: [UInt16] = [
    0, 3, 2,
    0, 1, 3
  ]
  let indexBuffer: MTLBuffer
  
  // MARK: - 4 adding color
  var colors: [simd_float3] = [
    [1, 0, 0], // red
    [0, 1, 0], // green
    [0, 0, 1], // blue
    [1, 1, 0]  // yellow
  ]
  let colorBuffer: MTLBuffer
  
  let vertexBuffer: MTLBuffer

  init(device: MTLDevice, scale: Float = 1) {
    vertices = vertices.map {
      $0 * scale
    }
    guard let vertexBuffer = device.makeBuffer(
      bytes: &vertices,
      length: MemoryLayout<Float>.stride * vertices.count,
      options: [])
    else {
      fatalError("Unable to create quad vertex buffer")
    }
    self.vertexBuffer = vertexBuffer
    
    // MARK: - 2 adding index buffer initialization
    guard let indexBuffer = device.makeBuffer(
      bytes: &indices,
      length: MemoryLayout<UInt16>.stride * indices.count,
      options: [])
    else {
      fatalError("Unable to create quad index buffer")
    }
    self.indexBuffer = indexBuffer
    
    // MARK: - 4 adding color buffer initialization
    guard let colorBuffer = device.makeBuffer(
      bytes: &colors,
      length: MemoryLayout<simd_float3>.stride * indices.count,
      options: [])
    else {
        fatalError("Unable to create quad color buffer")
      }
    self.colorBuffer = colorBuffer
  }
}

