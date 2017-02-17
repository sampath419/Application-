module WasteLogHelper
  WASTE_TYPES = [{name: 'classicRecycling',color: '#007AFF'},
                 {name: 'occCardboard',color: '#FF9500'},
                 {name: 'organicWaste',color: '#4CD964'},
                 {name: 'operationalWaste',color: '#FF3B30'}]

  def date_format(date)
    date.strftime('%m/%d/%Y')
  end

  def get_graph_data(store_id, days)
    waste_log_array = []
    if days == 7
      fetch_store = 'by_store_last7'
    else
      fetch_store = 'by_store_last30'
    end
    WASTE_TYPES.each do |waste_type|
      if days == 7
        waste_log_array << WasteType.find_by_name(waste_type[:name]).waste_log.by_store_last7(store_id).sum(&:quantity).round(2)
      else
        waste_log_array << WasteType.find_by_name(waste_type[:name]).waste_log.by_store_last30(store_id).sum(&:quantity).round(2)
      end
    end
    total_log_found = waste_log_array.sum
    waste_log_array << waste_log_array.first(3).sum
    waste_log_array.map{|log_size| (100*log_size.round(2)/total_log_found.round(2)).round(2) unless total_log_found==0}
  end

  def build_graph_hash(graph_data)
    graph_array = []
    WASTE_TYPES.each_with_index do |waste_type,index|
        type_data = WasteType.find_by_name(waste_type[:name])
        graph_array << { name: type_data.name, y: graph_data[index].to_f, color: waste_type[:color], sliced: true,}
    end
    graph_array
  end

  def get_waste_log_data(store_id, days='7')
    if days=='7'
      waste_logs = WasteLog.by_store_last7(store_id)
      graph_data = get_graph_data(store_id,7)
    else
      waste_logs = WasteLog.by_store_last30(store_id)
      graph_data = get_graph_data(store_id,30)
    end

    graph_hash = build_graph_hash(graph_data)
    [waste_logs, graph_data, graph_hash]
  end
end
