module SortMod  
  @@des_cmp = lambda{ |a,b| return a <=> b}
  @@asc_cmp = lambda{ |a,b| return b <=> a}
  
  # Open API: Sorting given array<ary>.
  def sort(ary, desc=true)
    nary = []
    ary.each{ |item|; nary << item; }
    csort(nary, desc ? @@des_cmp : @@asc_cmp)    
  end
  
  # Customized sorting algorithm.
  def csort(ary, cmp)
    raise RuntimeError, "Muse implement <csort> method!"
  end
  
  # Swap ary[i] with ary[j]
  def swap(ary, i, j)
    ary[i], ary[j] = ary[j], ary[i]
  end
  
  # Open API: In place sorting on given array<ary>
  def sort?(ary, cmp, desc=true)    
    csort(ary, cmp, desc ? @@des_cmp : @@asc_cmp)
    cmp
  end
  
  public :sort, :sort?
  protected :csort, :swap  
end