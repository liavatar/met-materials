
import MetalKit

public class Renderer: NSObject, MTKViewDelegate {
  
  public var device: MTLDevice!
  var queue: MTLCommandQueue!
  var pipelineState: MTLComputePipelineState!
  var time: Float = 0
  
  override public init() {
    super.init()
    initializeMetal()
  }
  
  func initializeMetal() {
    device = MTLCreateSystemDefaultDevice()
    queue = device!.makeCommandQueue()
    do {
      let library = device.makeDefaultLibrary()
      guard let kernel = library?.makeFunction(name: "compute") else { fatalError() }
      pipelineState = try device.makeComputePipelineState(function: kernel)
    } catch let e {
      print(e)
    }
  }
  
  public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
  
  public func draw(in view: MTKView) {
    time += 0.01
    guard let commandBuffer = queue.makeCommandBuffer(),
      let commandEncoder = commandBuffer.makeComputeCommandEncoder(),
      let drawable = view.currentDrawable else { fatalError() }
    commandEncoder.setComputePipelineState(pipelineState)
    commandEncoder.setTexture(drawable.texture, index: 0)
    commandEncoder.setBytes(&time, length: MemoryLayout<Float>.size, index: 0)
    var width = pipelineState.threadExecutionWidth
    var height = pipelineState.maxTotalThreadsPerThreadgroup / width
    let threadsPerGroup = MTLSizeMake(width, height, 1)
    width = Int(view.drawableSize.width)
    height = Int(view.drawableSize.height)
    let threadsPerGrid = MTLSizeMake(width, height, 1)
    commandEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerGroup)
    commandEncoder.endEncoding()
    commandBuffer.present(drawable)
    commandBuffer.commit()
  }
}
