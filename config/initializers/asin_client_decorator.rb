module ASIN
	Client.module_eval do

		def search_keywords(*keywords)
	    params = keywords.last.is_a?(Hash) ? keywords.pop : {:SearchIndex => :Books, :ResponseGroup => :Medium}
	    response = call(params.merge(:Operation => :ItemSearch, :Keywords => keywords.join(' ')))
	    return [arrayfy(response['ItemSearchResponse']['Items']['Item']).map {|item| handle_type(item, :item)}, response['ItemSearchResponse']['Items']['TotalResults']]
	  end	

	  def item_search(node_id, search_index)
      response = call({:Operation => :ItemSearch, :BrowseNode => node_id, SearchIndex: search_index, Condition: "All", ResponseGroup: "Medium"})
    end

    def lookup(*asins)
      params = asins.last.is_a?(Hash) ? asins.pop : {:ResponseGroup => :Medium}
      response = call(params.merge(:Operation => :ItemLookup, :ItemId => asins.join(',')))
      arrayfy(response['ItemLookupResponse']['Items']['Item']).map {|item| handle_type(item, :item)}
    end
	end
end