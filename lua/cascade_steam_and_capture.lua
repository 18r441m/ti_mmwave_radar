local host_ip = "192.168.33.50"
local fpga_ip = "192.168.33.30"  -- Placeholder for FPGA destination IP address
local fpga_mac = "AA:BB:CC:DD:EE:FF"  -- Placeholder for FPGA MAC address
local config_port = 4096  -- Placeholder for the config port
local record_port = 4098  -- Port used for streaming data

local radar_devices = {4, 3, 2, 1}  -- Device IDs for slaves (3, 2, 1) and master (1)

function ConfigureEthernet()
    -- Initialize Ethernet with the provided host and FPGA information
    ar1.CaptureCardConfig_EthInit(host_ip, fpga_ip, fpga_mac, config_port, record_port)
    WriteToLog("Ethernet configuration for specific host IP successful.\n", "green")
end

function ConfigureRadarDevices()
    -- Loop through each radar device in the cascade and configure it for continuous streaming
    for _, RadarDeviceId in ipairs(radar_devices) do
        local startFreqConst = 77.0 -- Example start frequency, modify as needed
        local digOutSampleRate = 8000 -- Example digital output sample rate, modify as needed
        local rxGain = 30 -- Example RX gain, modify as needed
        local hpfCornerFreq1 = 0 -- Example HPF corner frequency 1, modify as needed
        local hpfCornerFreq2 = 0 -- Example HPF corner frequency 2, modify as needed
        local tx0OutPowerBackoffCode = 0 -- Example TX power backoff code for TX0, modify as needed
        local tx1OutPowerBackoffCode = 0 -- Example TX power backoff code for TX1, modify as needed
        local tx2OutPowerBackoffCode = 0 -- Example TX power backoff code for TX2, modify as needed
        local tx0PhaseShifter = 0 -- Example phase shifter value for TX0, modify as needed
        local tx1PhaseShifter = 0 -- Example phase shifter value for TX1, modify as needed
        local tx2PhaseShifter = 0 -- Example phase shifter value for TX2, modify as needed

        -- Configure continuous streaming for this radar device
        ar1.ContStrConfig_mult(RadarDeviceId, startFreqConst, digOutSampleRate, rxGain, hpfCornerFreq1, hpfCornerFreq2, 
                               tx0OutPowerBackoffCode, tx1OutPowerBackoffCode, tx2OutPowerBackoffCode, 
                               tx0PhaseShifter, tx1PhaseShifter, tx2PhaseShifter)
        
        WriteToLog("Configured continuous streaming for Radar Device " .. RadarDeviceId .. ".\n", "blue")
    end
end

function StartContinuousStreaming()
    ConfigureEthernet()
    ConfigureRadarDevices()

    -- Enable continuous streaming mode in the order: Slaves (4, 3, 2), then Master (1)
    for i = 1, #radar_devices - 1 do  -- Trigger all slaves first
        ar1.ContStrModEnable_mult(radar_devices[i])
        WriteToLog("Started continuous streaming for Slave Device " .. radar_devices[i] .. ".\n", "blue")
    end

    -- Finally, trigger the Master device
    ar1.ContStrModEnable_mult(radar_devices[#radar_devices])
    WriteToLog("Started continuous streaming for Master Device " .. radar_devices[#radar_devices] .. ".\n", "blue")
end

-- Start the streaming process automatically
StartContinuousStreaming()
