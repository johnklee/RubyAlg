require "alg/ml/DTree"

class BasicDTree
  include DTree
  
  def createTree(dataSet, labels)
    classList=dataSet.collect{|item| item[-1]}    
    if len(classList) == classList.count(classList[0])  # 所有的 class 都是同一類.
      return classList[0]
    elsif len(dataSet) == 1                             # 已經沒有 feature 可以 split 了.
      #printf("\t[Test] Majority of %s: %s\n", dataSet, majorityCnt(classList))  
      return majorityCnt(classList)
    end
    
    bestFeat = chooseBestFeatureToSplit(dataSet)    
    #printf("\t[Test] Best Feat=#{bestFeat} (#{labels[bestFeat]})...\n")  
    bestFeatLabel = labels[bestFeat]  
    myTree = {bestFeatLabel=>{}}
    subLabels = labels[0...bestFeat]+labels[bestFeat+1..-1]
    #printf("\t[Test] classList: #{classList}\n")
    #printf("\t[Test] Labels:\n\t#{labels}\n\t#{subLabels}\n\n")
    return classList if bestFeat<0
    uniqueVals = dataSet.collect{|item| item[bestFeat]}.to_set
    for value in uniqueVals
      myTree[bestFeatLabel][value] = createTree(splitDataSet(dataSet, bestFeat, value), Array.new(subLabels))
    end   
    return myTree    
  end
end