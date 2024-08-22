local host_ip = "192.168.33.50"
local data_port = 4098
local command_port = 5000

function ConfigureEthernet()
    ar1.CaptureCardConfig_EthInit_mult(1, host_ip, data_port)
    WriteToLog("Ethernet configuration for specific host IP successful.\n", "green")
end

function StartContinuousStreaming()
    ConfigureEthernet()

    ar1.CaptureCardConfig_Mode_mult(1, 1)

    WriteToLog("Started continuous streaming over Ethernet to specific host.\n", "blue")

    if (RadarDevice[4]==1) then Framing_Control(4, 1) end
    if (RadarDevice[3]==1) then Framing_Control(3, 1) end
    if (RadarDevice[2]==1) then Framing_Control(2, 1) end
    Framing_Control(1, 1)
end

function StopContinuousStreaming()
    if (RadarDevice[4]==1) then Framing_Control(4, 0) end
    if (RadarDevice[3]==1) then Framing_Control(3, 0) end
    if (RadarDevice[2]==1) then Framing_Control(2, 0) end
    Framing_Control(1, 0)

    ar1.CaptureCardConfig_StopRecord_mult(1)
    WriteToLog("Stopped continuous streaming to specific host.\n", "blue")
end

function ListenForCommands()
    local udpSocket = assert(socket.udp())
    udpSocket:setsockname("*", command_port)
    udpSocket:settimeout(0)

    while true do
        local command, ip, port = udpSocket:receivefrom()
        if command then
            WriteToLog("Received command: " .. command .. " from " .. ip .. "\n", "yellow")
            if command == "START" then
                StartContinuousStreaming()
            elseif command == "STOP" then
                StopContinuousStreaming()
            else
                WriteToLog("Unknown command: " .. command .. "\n", "red")
            end
        end
        RSTD.Sleep(100)
    end

    udpSocket:close()
end

ListenForCommands()