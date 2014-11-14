require "alg/sort/SortMod"

class SelectSort
  # http://localhost/jforum/posts/list/937.page
  include SortMod
  
  def csort(ary, cmp) 
    if(ary.size>1)
      (0..ary.size-2).each do |i|
        (i..ary.size-1).each do|j|
          if (cmp.call(ary[i],ary[j])==1)
            swap(ary, i, j)
          end
        end
      end
    end
    ary
  end
end