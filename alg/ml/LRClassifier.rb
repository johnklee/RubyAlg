require "alg/ml/MLCore"
require "enumerator"

# http://localhost/jforum/posts/list/2230.page
class LRClassifier
  include MLCore
  
  # Wiki - Gradient Descent: http://en.wikipedia.org/wiki/Gradient_descent
  # Gradient descent is a first-order optimization algorithm to find a local minimum of a function.
  # 
  # Argument
  #   * dataMatIn: Data attribute array list.
  #   * classLabels: The label [0,1] of each data corresponding to <dataMatIn>.
  #   * alpha: Used to fast or slow the judgement of weighting.
  #   * maxCycles: Loop to appy Gradient Descent.
  # Return
  #   The optimized weighting array. 
  def gradAscent(dataMatIn, classLabels, alpha=0.001, maxCycles=500, bDebug=false)
    m,n = shape(dataMatIn)                                        # m 指 data size; n 指  attribute 數目.
    weights = Array.new(n,1)                                      # 初始 weight matrix 值為 1.
    maxCycles.times do |i|
      h = Array.new(m,0)                                          # h is the array of sigmod result of each instance
      dataMatIn.size.times do |j|
        h[j]=sigmod(dataMatIn[j].multi(weights).sum)              # Execution of each data instance
      end
      error = classLabels.minus(h)                                # Expection - Execution      
      
      # 重新計算 weight matrix
      dataMatIn.size.times do |j|
        weights = weights.plus((dataMatIn[j].multi(alpha).multi(error[j])))
      end       
      
      printf("\t[Loop#{i}] Weighting:\n%s\n\n", weights) if bDebug      
    end
    return weights
  end
  
  # Wiki - Stochastic gradient descent: http://en.wikipedia.org/wiki/Stochastic_gradient_descent
  # Argument
  #   * dataMatrix: Data attribute array list.
  #   * classLabels: The label [0,1] of each data corresponding to <dataMatIn>.
  #   * alpha: Used to fast or slow the judgement of weighting.
  #   * maxCycles: Loop to appy Gradient Descent.
  # Return
  #   The optimized weighting array.
  def  stocGradAscent0(dataMatrix, classLabels, alpha=0.001, maxCycles=500, bDebug=false)
    m,n = shape(dataMatrix)
    weights = Array.new(n,1)
    m.times do |i|
      h = sigmod(dataMatrix[i].multi(weights).sum)
      error = classLabels[i]-h
      weights = weights.plus(dataMatrix[i].multi(alpha*error))
    end
    weights
  end
  
  # Enhanced Stochastic gradient descent with dynamic alpha value
  def stocGradAscent1(dataMatrix, classLabels, maxCycles=150)
    m,n = shape(dataMatrix)
    weights = Array.new(n,1)
    idxAry=Array(0...m)
    maxCycles.times do |i| 
      m.times do |j|
        k = idxAry.delete_at(Random.rand(idxAry.size))
        alpha = 4/(1.0+j+i)+0.0001    # apha decreases with iteration, 
                                      # does not go to 0 because of the constant        
        h = sigmod(dataMatrix[k].multi(weights).sum)
        error = classLabels[k]-h
        weights = weights.plus(dataMatrix[k].multi(alpha*error))
      end
    end   
    weights 
  end
  
  # Classify input <data2Classify> with returned label 0 or 1.
  #
  # Argument
  #   * data2Classify: Data to classify
  #   * weightingMtx: Weighting array 
  # Return
  #   Classified result. (0 or 1)
  def classifyLR(data2Classify, weightingMtx)
    t = sigmod(data2Classify.multi(weightingMtx).sum)
    if(t>=0.5)
      return 1
    else
      return 0
    end
  end
end