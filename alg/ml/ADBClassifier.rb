# http://localhost/jforum/posts/list/2231.page
require "alg/ml/MLCore"
require "enumerator"

class ADBClassifier
  include MLCore
  
  # 使用給定的 stump(dimen, threshVal, threshIneq) 對 data set=dataMatrix 進行 classification.
  #
  # Argument
  #   * dataMatrix
  #   * dimen
  #   * threshVal: Threshold value
  #   * threshIneq: 'lt' means less than and equal to <threshVal>; otherwise great than <threshVal>.
  # Return
  #   Classification result array: -1 means miss; 1 means match.
  def stumpClassify(dataMatrix,dimen,threshVal,threshIneq)
    retArray = []
    dataMatrix.each do |d|
      if threshIneq == 'lt'
        retArray << ((d[dimen]<=threshVal)?-1:1)
      else
        retArray << ((d[dimen]>threshVal)?-1:1)
      end
    end
    retArray
  end
  
  # 根據 weight matrix D 建立最佳 stump.
  #
  # Argument
  #   * dataArr: Data attribtes array
  #   * classLabels: Class labels accordingly.
  #   * d: Weighting vector
  # Return
  #   [bestStump,minError,bestClasEst]
  def buildStump(dataArr,classLabels,d)
    m,n = shape(dataArr) # m 為 data set size ; n 為 feature size. 
    numSteps = 10.0; bestStump = {}; bestClasEst = zeros(m,1);
    minError = Float::INFINITY
    n.times do |i| # Loop over all dimensions
      data = dataArr.collect{|da| da[i]}
      rangeMin=data.min; rangeMax=data.max
      stepSize = (rangeMax-rangeMin)/numSteps
      (0..numSteps).each do |j| #loop over all range in current dimension
        for inequal in ['lt', 'gt']
          threshVal = (rangeMin + float(j) * stepSize)
          predictedVals = stumpClassify(dataArr,i,threshVal,inequal)
          errArr = ones(m,0)
          classLabels.each_with_index do |v,k|
            errArr[k]=0 if v==predictedVals[k]
          end
          #printf("\t[D] d.multi(errArr):\n%s\n%s\n", d, errArr)
          weightedError=d.multi(errArr).sum #calc total error multiplied by <d>
          #printf("\t[Test] dim=#{i};thresh=#{threshVal};ineq=#{inequal}: #{weightedError}\n")
          if weightedError < minError
            minError = weightedError 
            bestClasEst=predictedVals
            bestStump['dim'] = i  
            bestStump['thresh'] = threshVal  
            bestStump['ineq'] = inequal
          end
        end
      end
    end
    
    return [bestStump,minError,bestClasEst]
  end
  
  # AdaBoost training with decision stumps.
  #
  # Argument
  #   * dataArr: Data attributes array
  #   * classLabels: Class labels accordingly
  #   * numIt: Iteration/loop limition
  # Return
  #   weakClassArr
  def adaBoostTrainDS(dataArr,classLabels,numIt=40)
    weakClassArr = []
    m = shape(dataArr)[0]
    d = Array.new(m, 1.0/m) # init D to all equal
    aggClassEst = zeros(m,0)
    numIt.times do |i|
      bestStump,error,classEst = buildStump(dataArr,classLabels,d)  # build Stump
      #printf("\t[Test] classEst=%s\n", classEst)
      alpha = float(0.5*Math.log((1.0-error)/[error,1e-16].max))    #calc alpha, throw in max(error,eps) to account for error=0
      #printf("\t[Test] alpha=#{alpha}\n")
      bestStump['alpha'] = alpha
      weakClassArr  << bestStump                                    #store Stump Params in Array
      # expon = multiply(-1*alpha*mat(classLabels).T,classEst)
      expon = (classLabels.multi(classEst)).multi(-1*alpha)
      #printf("\t[Test] d=#{d} (expon=#{expon})\n")
      d = d.to_enum(:each_with_index).collect{|v,i| v*Math.exp(expon[i])}
      #d = d.multi(Math.exp(expon))
      #printf("\t[Test] d=#{d} (d.sum=#{d.sum})\n") 
      d = d/(d.sum)
      printf("\t[Test] d=#{d}\n")
      #calc training error of all classifiers, if this is 0 quit for loop early (use break)  
      #aggClassEst += alpha*classEst
      aggClassEst.plus!(classEst.multi(alpha))
      #printf("\t[Test] aggClassEst=%s\n", aggClassEst)
      aggErrors = []
      aggClassEst.each_with_index do |v,i|
        #printf("\t[Test] sign(%s)=%s <-> %s\n", v, sign(v), int(classLabels[i]))
        if Float(sign(v))!=classLabels[i]
          aggErrors << 1
        else
          aggErrors << 0
        end
      end
      errorRate = aggErrors.sum/Float(m)   
      printf("\t[Loop#{i+1}] total error: #{errorRate}...\n")  
      break if errorRate == 0.0 
    end  
    return weakClassArr
  end
  
  # AdaBoosting Classify Method
  #
  # Argument
  #   * datToClass: Data attributes array to classify
  #   * classifierArr: Training data returned from API:adaBoostTrainDS
  # Return
  #   Classified resuult. 
  def adaClassify(datToClass,classifierArr)
    m = shape(datToClass)[0]
    aggClassEst = zeros(m,0)
    len(classifierArr).times do |i|
      classEst = stumpClassify(datToClass,
                               classifierArr[i]['dim'], 
                               classifierArr[i]['thresh'],  
                               classifierArr[i]['ineq'])#call stump classify
      # aggClassEst += classifierArr[i]['alpha']*classEst
      aggClassEst.plus!(classEst.multi(classifierArr[i]['alpha']))
    end
    return sign(aggClassEst)
  end
end