@time begin
file = open("dump_prob.pcap", "r")

packet_array = Vector{Vector{Any}}() #Массив под пакеты
tcp_array = Vector{Vector{Any}}() #Массив под tcp 
http_array = Vector{Vector{Any}}() #Массив под http

pcap_header = read(file, 24) #Чтение заголовка 24 байта


#Заполнение массива пакетами
for i in range(1,116)
	packet_header = read(file, 16) #Чтение заголовка 16 байт
	#print(packet_header)
	packet_length = UInt16(packet_header[9]) + UInt16(packet_header[10]) << 8 #Длина пакета 9 и 10 байт
	packet = read(file, packet_length)
	#print(packet_length)
	push!(packet_array, packet)
	#print(packet_header)
	#print(packet_length)

	print("\n")
	#print(packet_array)
end

#print(packet_array)

#Выделение tcp и загрузка в массив
for i in range(1,length(packet_array))
	load_packet = packet_array[i]
	#print(load_packet)
	ip_hdr = load_packet[15:34] #Чтение из ip заголовка 15-34 байт
	#print(ip_hdr)
	protocol = ip_hdr[10]  #Протокол 10 байт
	#print("\n")
	if protocol == 6
		push!(tcp_array, load_packet[35:end])
	end
end
#print(tcp_array)

#Выделение поля Data из tcp и загрузка в массив
for i in range(1,length(tcp_array))
	load_packet = tcp_array[i]
	offset = (load_packet[13] & 0xf0) >> 4
	data = load_packet[offset * 4 + 1:end]
	print("\n\n")
	if i == 1                               #Первый пакет сразу записывается в массив, из него берутся seq и ack
		push!(http_array, data)
		global previous_seq = load_packet[5:8]
		global previous_ack = load_packet[9:12]
		global k = i
	else
		seq = load_packet[5:8] #Если пакет не первый, берем seq и ack
		ack = load_packet[9:12]
		if (seq == previous_ack) | ((seq == previous_seq) & (ack == previous_ack)) #Проверяем, чтобы пакет был из того же потока, что и предыдущий, также я заметил, что после запроса GET приходят два пакета с одинаковыми seq и ack (один служебный, второй с данными)
			append!(http_array[k], data)
		else
			push!(http_array, data)
			global k = k + 1
		end
		global previous_seq = seq
		global previous_ack = ack
	end
	#print("\n")
end

#print(http_array)

close(file)
end


