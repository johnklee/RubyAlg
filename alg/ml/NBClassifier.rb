require "alg/ml/MLCore"
require "enumerator"

class NBClassifier
  include MLCore
  
  # Calculate Naive Bayes
  #
  # Argument
  #   * trainMatrix: Training instance vectory list
  #   * trainCategory: Category list corresponding to <trainMatrix>
  # Return
  #   返回 : {c1->[P(c1),P(w|c1)],c2->[p(c2),p(w|c2),...]} 
  def trainNB0(trainMatrix, trainCategory)
    #printf("\t[Test] trainCategory: %s\n", trainCategory)
    numTrainDocs = len(trainMatrix)                     # 求出總 Posting 數目.
    numWords = len(trainMatrix[0])                      # 求出總 Features 數目.
    rtnMap = {} 
    cateList = Set.new(trainCategory).sort 
    
    for cate in cateList      
      rtnMap[cate]=[trainCategory.count(cate)/float(numTrainDocs)] # 求出  P(ci)     
      rtnMap[cate] << Array.new(numWords,0)
      rtnMap[cate] << 0 
      #printf("%s->%s\n", cate, rtnMap[cate]) 
    end
    
    trainMatrix.each_with_index do |vec, i|
      #printf("\t[Test] Cate=%s\n", trainCategory[i])
      #printf("\t[Test] Combine:\n%s\n%s\n", rtnMap[trainCategory[i]][1], vec)
      rtnMap[trainCategory[i]][1].combine!(vec)
      rtnMap[trainCategory[i]][2]+=vec.sum
    end
    
    rtnMap.each do |k, v|
      #printf("\t[Test]")
      v[1]/=v[2]
    end
    rtnMap
  end
  
  # Calculate Naive Bayes (with Smoothing and Log)
  #
  # Argument
  #   * trainMatrix: Training instance vectory list
  #   * trainCategory: Category list corresponding to <trainMatrix>
  # Return
  #   返回 : {c1->[P(c1),P(w|c1)],c2->[p(c2),p(w|c2),...]} 
  def trainNB1(trainMatrix,trainCategory)
    numTrainDocs = len(trainMatrix)                     # 求出總 Posting 數目.
    numWords = len(trainMatrix[0])                      # 求出總 Features 數目.
    rtnMap = {} 
    cateList = Set.new(trainCategory).sort 
        
    for cate in cateList      
      rtnMap[cate]=[Math.log(trainCategory.count(cate)/float(numTrainDocs))] # 求出  P(ci)
      rtnMap[cate] << Array.new(numWords,1) # Smoothing: 每個 token 的 count 的初始值設為 1
      rtnMap[cate] << 2.0                   # Smoothing: Avoid divided by zero
      #printf("%s->%s\n", cate, rtnMap[cate]) 
    end
        
    trainMatrix.each_with_index do |vec, i|
      #printf("\t[Test] Cate=%s\n", trainCategory[i])
      #printf("\t[Test] Combine:\n%s\n%s\n", rtnMap[trainCategory[i]][1], vec)
      rtnMap[trainCategory[i]][1].combine!(vec)
      rtnMap[trainCategory[i]][2]+=vec.sum
    end
        
    rtnMap.each do |k, v|
      #printf("\t[Test]")
      v[1]/=v[2]
      v[1].map!{|i| Math.log(i)}
    end
    rtnMap
  end
  
  # P(ci|w) = P(w|ci) * P(ci) / P(w) - 因為我們目的是比較值的大小, 故省略 P(w).
  #
  # Argument
  #   * vec2Classify: Vectory instance to classify
  #   * trnMap: Trained map (Returned by API:trainNB0-1)
  # Return
  #   Array to holding sorting classified result. [[c1,p1],[c2,p2]...[cn,pn]]]
  #   The first element is the classified result with highly possibility. 
  def classifyNB(vec2Classify, trnMap)
    csMap = {}
    trnMap.each do |cate,td|
      csMap[cate]=td[0]+td[1].multi(vec2Classify).sum
    end
    csMap.sort_by{|k,v| v}.reverse    
  end
end