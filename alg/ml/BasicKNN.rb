require "alg/ml/KNN"

class BasicKNN
  include KNN
  
  def classify(group, labels, inst, k, do_norm=false)
    dataSetSize = group.size
    group = normData(group) if do_norm
    
    # 1) Distance calculation
    distAry=[]
    group.each_with_index do |v,i|
      d=0
      v.each_with_index do |e,j|
        d+=(e-k[j]).abs**2
      end
      distAry << [d, labels[i]]      
    end
    distAry.sort!{|a,b| a[0]<=>b[0]}
    
    # 2) Voting with lowest k distances
    classCnt={}
    (0...k).each do |i|
      l=distAry[i][1]
      classCnt[l]=classCnt.fetch(l,0)
    end
    
    return classCnt.sort_by{|k,v| v}.reverse[0][0]
  end
end