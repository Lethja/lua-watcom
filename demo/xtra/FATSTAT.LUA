#!/usr/bin/env lua

H=[[This script shows what blocks are allocated to what files on a FAT12/16 formatted floppy disk image (.IMA).
When the -z option is present any junk data from unallocated clusters will be zeroed out.
This is sometimes referred to as "shredding" , doing so allows repeatable builds to be verified by checksum tools.
Always backup the IMA before using this tool with the -z option on it.]]

if #arg < 1 then print(arg[-1] .. " " .. arg[0] .. " [-z] [IMA FILES...]" .. '\n\n' .. H) os.exit(1) end

local function args()
    F={} for _,v in ipairs(arg) do if v=="-z" then Z=true else table.insert(F, v) end end
end

local function read_le16(str, offset)
    local a, b = str:byte(offset, offset + 1) return a + b * 256
end

local function read_le32(str, offset)
    local a, b, c, d = str:byte(offset, offset + 3) return a + b * 256 + c * 65536 + d * 16777216
end

local function read_fat12_table(f, fat_offset, fat_size)
    f:seek("set", fat_offset)
    local fat_data,fat,max_clusters=f:read(fat_size),{},math.floor(fat_size * 8 / 12)
    local function get_entry(i)
        local byte_index = math.floor(i * 1.5)
        local a,b=fat_data:byte(byte_index + 1)or 0,fat_data:byte(byte_index + 2)or 0
        if i % 2 == 0 then return a + (b & 0x0F) * 256 else return (a >> 4) + b * 16 end
    end
    for i = 2, max_clusters - 1 do fat[i] = get_entry(i) end return fat
end

local function read_fat16_table(f, fat_offset, fat_size)
    f:seek("set", fat_offset) local fat_data,fat=f:read(fat_size),{}
    for i = 2, #fat_data - 1, 2 do
        local lo,hi=fat_data:byte(i),fat_data:byte(i + 1) fat[((i-2)//2)+2] = lo + hi * 256
    end return fat
end

local function detect_fat_type(total_sectors, reserved_sectors, num_fats, sectors_per_fat, root_dir_sectors, sectors_per_cluster)
    local cluster_count = math.floor((total_sectors - reserved_sectors - (num_fats * sectors_per_fat) - root_dir_sectors) / sectors_per_cluster)
    if cluster_count < 4085 then return 12
    elseif cluster_count < 65525 then return 16
    else return 32 end
end

local function cluster_chain(fat, start_cluster)
    local chain, current = {}, start_cluster
    while current >= 2 and current < 0xFF8 do
        table.insert(chain, current) current = fat[current]
    end return chain
end

local function format_cluster_ranges(clusters)
    table.sort(clusters) local ranges, i = {}, 1
    while i <= #clusters do
        local start = clusters[i]
        local j = i
        while j + 1 <= #clusters and clusters[j + 1] == clusters[j] + 1 do
            j = j + 1
        end
        local finish = clusters[j]
        if start == finish then
            table.insert(ranges, string.format("<%d>", start))
        else
            table.insert(ranges, string.format("<%d-%d>", start, finish))
        end
        i = j + 1
    end
    return table.concat(ranges, " ")
end

local function print_directory_entries(f, offset, entries, fat)
    f:seek("set", offset)
    for _ = 1, entries do
        local entry = f:read(32)
        if not entry then break end
        local first_byte = entry:byte(1)
        if first_byte == 0x00 then break end
        local attr = entry:byte(12)
        if first_byte ~= 0xE5 and (attr & 0x08) == 0 then
            local name,ext = entry:sub(1, 8):gsub(" +$", ""),entry:sub(9, 11):gsub(" +$", "")
            local fullname = name .. (ext ~= "" and "." .. ext or "")
            local start_cluster = read_le16(entry, 27)
            local clusters = cluster_chain(fat, start_cluster)
            io.write(string.format("\t%12s: %s\n", fullname, format_cluster_ranges(clusters)))
        end
    end
end

local function print_free_clusters(fat, f, data_start, cluster_size)
    io.write("\n\t  Free Space: ")
    local free, zero = {}, string.rep("\0",cluster_size)
    for i = 2, #fat do
        if fat[i] == 0 then
            table.insert(free, i)
            if Z then
                local offset = data_start + (i - 2) * cluster_size
                f:seek("set", offset)
                f:write(zero)
            end
        end
    end
    print(format_cluster_ranges(free))
end

args() for _,file in ipairs(F) do
    local f = io.open(file, (Z and "r+b" or "rb"))
    if f then
        print(file .. ":")
        local boot = f:read(512)
        assert(boot:sub(1, 1):byte() == 0xEB or boot:sub(1, 1):byte() == 0xE9, "Invalid boot sector")

        local bytes_per_sector     = read_le16(boot, 12)
        local sectors_per_cluster  = boot:byte(14)
        local reserved_sectors     = read_le16(boot, 15)
        local num_fats             = boot:byte(17)
        local root_entries         = read_le16(boot, 18)
        local total_sectors        = read_le16(boot, 19) or read_le32(boot, 32)
        local sectors_per_fat      = read_le16(boot, 23)
        local root_dir_sectors     = math.ceil(root_entries * 32 / bytes_per_sector)
        local fat_offset           = reserved_sectors * bytes_per_sector
        local fat_size             = sectors_per_fat * bytes_per_sector
        local root_dir_offset      = (reserved_sectors + num_fats * sectors_per_fat) * bytes_per_sector

        local fat_type = detect_fat_type(total_sectors, reserved_sectors,num_fats, sectors_per_fat, root_dir_sectors, bytes_per_sector)
        print(string.format("\t       FAT type: FAT%s", fat_type))
        print(string.format("\t   Bytes/sector: %d", bytes_per_sector))
        print(string.format("\tSectors/cluster: %d", sectors_per_cluster))print()

        local fat = fat_type == 12 and read_fat12_table(f, fat_offset, fat_size) or fat_type == 16 and read_fat16_table(f, fat_offset, fat_size) or error("Not FAT12/16")

        print_directory_entries(f, root_dir_offset, root_entries, fat)
        print_free_clusters(fat, f, (reserved_sectors + (num_fats * sectors_per_fat) + root_dir_sectors) * bytes_per_sector, sectors_per_cluster * bytes_per_sector)

        f:close()print()
    end
end
