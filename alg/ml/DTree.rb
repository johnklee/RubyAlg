
require 'set'
require 'yaml'
require 'alg/ml/MLCore'

# http://localhost/jforum/posts/list/2221.page
module DTree
  include MLCore
  
  # Function to calculate the Shannon entropy of a dataset
  # Argument
  #   - dataSet: Data set array. Each item is an array with last one element as label.
  def calcShannonEnt(dataSet)
    numEntries = dataSet.size
    labelCounts = {}
    dataSet.each_with_index do |inst, pos|
      label = inst[-1]
       labelCounts[label]=labelCounts.fetch(label,0)+1
    end
    shannonEnt = 0.0
    labelCounts.each_pair do |k, v|
      prob=v.to_f/numEntries
      shannonEnt-=prob*Math.log2(prob)
    end
    shannonEnt
  end
  
  # Dataset splitting on a given feature
  # - Argument
  #   * dataSet : 原始 data set  
  #   * axis : 切割 Feature 的 column index.  
  #   * value : 切割 Feature 的某個值. 
  def splitDataSet(dataSet, axis, value)
    retDataSet = [] 
    for featVec in dataSet
      if featVec[axis] == value
        reducedFeatVec=featVec[0...axis]+featVec[axis+1..-1]
        retDataSet << reducedFeatVec
      end
    end
    retDataSet
  end
  
  # Choosing the best feature to split on
  # - Argument  
  #   * dataSet: 原始 data set 
  # - Return
  #   返回有最大 Information gain 的 Feature column.
  def chooseBestFeatureToSplit(dataSet)
    numFeatures = len(dataSet[0]) - 1 # 最後一個欄位是 Label
    baseEntropy = calcShannonEnt(dataSet)  
    bestInfoGain = 0.0 ; bestFeature = -1
    numFeatures.times do |i|
      featList = dataSet.collect{|itm| itm[i]}
      uniqueVals = featList.to_set
      newEntropy = 0.0
      
      for value in uniqueVals
        subDataSet = splitDataSet(dataSet, i, value) 
        prob = len(subDataSet) / (len(dataSet)).to_f
        newEntropy += prob * calcShannonEnt(subDataSet)
      end 
      
      infoGain = baseEntropy - newEntropy  # Information gain: Split 會讓 data 更 organized, 所以 Entropy 會變小.        
      if infoGain > bestInfoGain
        bestInfoGain = infoGain
        bestFeature = i   
      end   
    end
    #return 0 if bestFeature<0
    return bestFeature
  end
  
  # Choose majority class and return.
  # - Argument 
  #   * classList: 類別的 List. 
  # - Return
  #   返回 List 中出現最多次的類別.
  def majorityCnt(classList)
    classCnt = {} 
    for vote in classList
      classCnt[vote] = classCnt.fetch(vote,0)+1
    end
    return classCnt.sort_by{|k,v| v}.reverse[0]
  end
  
  # Customized API:　Tree-building code.
  # - Argument  
  #   * dataSet: 原始 data set  
  #   * labels: 對應 class 標籤的文字說明.
  # - Return
  #   返回建立的 Decision Tree.
  def createTree(dataSet, labels)
    raise RuntimeError, "Muse implement <createTree> method!"
  end
  
  # Classification function for an existing decision tree
  # - Arguments
  #   * inputTree: 建立的 Decision Tree Object
  #   * featLabels: 
  #   * testVec: 進行  classify 的實例.
  # - Return
  #   返回 classify 的結果.
  def classify(inputTree, featLabels, testVec)
    #printf("\t[Test] inputTree=#{inputTree}\n")
    #printf("\t[Test] labels=#{featLabels}\n")
    #printf("\t[Test] inst=#{testVec}\n\n")
    firstStr = inputTree.keys()[0]          # 取出第一個 decision block
    secondDict = inputTree[firstStr]        # 取出對應 decision block 的 sub decision tree.
    featIndex = featLabels.index(firstStr)  # 取出該 decision block 對應 feature 的欄位.
    out = secondDict[testVec[featIndex]]
    if out.is_a? Hash
      return classify(out, featLabels, testVec)
    else
      return out
    end 
  end
  
  # Serialized Decision Tree to File System.
  # - Arguments
  #   * inTree: Decision tree object
  #   * filename: The file name to serialize the decision tree object.
  def storeTree(inTree, filename)
    File.open(filename, "w") do |file|
      file.puts YAML::dump(inTree)
    end
  end
  
  # De-Serialize Decision Tree from File System
  # - Arguments
  #   * filename: File name to de-serialize the decision tree object.
  # - Return
  #   The decision tree object.
  def grabTree(filename)
    inTree = nil
    File.open(filename, "r").each do |of|
      inTree = YAML::load(of)
    end
    inTree
  end
end