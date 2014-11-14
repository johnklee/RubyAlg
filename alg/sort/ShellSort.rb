require "alg/sort/SortMod"

class ShellSort
  # http://localhost/jforum/posts/list/941.page
  include SortMod
  
  def csort(ary, cmp) 
    if(ary.size>1)
      jmp = ary.size/2
      while jmp>0
        #printf("\t[Info] jmp=%d:\n", jmp)
        (0..jmp-1).each do |i|
          #printf("\t\ti=%d (%d)...\n", i, ary[i])
          (i+jmp..ary.size-1).step(jmp) do |j|
            #printf("\t\t\tj=%d (%d)...\n", j, ary[j])
            while (j-jmp)>=0 && cmp.call(ary[j-jmp], ary[j]) == 1
              #printf("\t\t\t\tswap(%d->%d,%d->%d)!\n", j-jmp, ary[j-jmp], j, ary[j])
              swap(ary, j-jmp, j)
              j-=jmp
            end
          end
        end        
        jmp/=2
      end
    end
    ary
  end
end