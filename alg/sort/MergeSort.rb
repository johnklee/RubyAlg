require "alg/sort/SortMod"

class MergeSort
  # http://localhost/jforum/posts/list/1222.page
  include SortMod
  
  def msort(ary, cmp, first, last)
    if ((first+1)<last)
      mid = (first+last)/2
      msort(ary, cmp, first, mid)
      msort(ary, cmp, mid, last)
      tmp = []
      indexA=first;indexB=mid;indexC=0; i=0
      #printf("\t[Info] msort(%d,%d)=%s...\n", first, last-1, ary[first...last])      
      if cmp.call(ary[mid-1], ary[mid])==1
        while (i<(last-first))
          if indexA >= mid
            tmp << ary[indexB]
            indexB+=1
          elsif indexB >= last
            tmp << ary[indexA]
            indexA+=1
          else
            if cmp.call(ary[indexA], ary[indexB]) == 1
              tmp << ary[indexB]
              indexB+=1 
            else
              tmp << ary[indexA]
              indexA+=1
            end                                
          end
          i+=1
        end
        #printf("\t\ttmp=%s\n", tmp)
        (first...last).each do |i|        
          ary[i]=tmp[i-first]
        end
      end      
      
      #printf("\t\tary=%s\n", ary)
    end
    ary
  end
  
  def csort(ary, cmp)
    return msort(ary, cmp, 0, ary.size)
  end
end