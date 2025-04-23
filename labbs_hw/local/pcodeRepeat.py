def process_repeating_bytes(input_str, repeat_times=1):
    """
    处理重复四次的字节模式，生成自定义重复次数的输出
    :param input_str: 输入字符串（必须每个字节重复四次）
    :param repeat_times: 期望的重复次数（默认1次）
    :return: 处理后的字符串
    """
    # 清理输入数据
    cleaned = input_str.strip().replace("\n", " ").split()
    
    # 验证输入格式
    if len(cleaned) % 4 != 0:
        raise ValueError("输入数据必须为4的倍数")
    
    # 提取唯一值并生成新序列
    unique_bytes = [cleaned[i] for i in range(0, len(cleaned), 4)]
    new_sequence = [byte for byte in unique_bytes for _ in range(repeat_times)]
    
    # 格式化为每8个字节换行
    formatted = []
    for i in range(0, len(new_sequence), repeat_times*8):
        line = " ".join(new_sequence[i:i+repeat_times*8])
        # # 保持原始的双空格分隔格式
        # if i % 16 == 8 and i !=0:  
        #     line = " " + line
        formatted.append(line)
    
    return "\n".join(formatted)

# 使用示例
if __name__ == "__main__":
    input_file='./xabs-hw/local/pcode4.txt'
    output_file='./xabs-hw/local/pcode1.txt'

    try:
        # 读取输入文件
        with open(input_file, 'r') as f:
            input_data = f.read()
        
        # 写入输出文件
        with open(output_file, 'w') as f:
            f.write(process_repeating_bytes(input_data, 1))
        
        print(f"处理完成！结果已保存到 {output_file}")
    
    except FileNotFoundError:
        print(f"错误：文件 {input_file} 不存在")
    except Exception as e:
        print(f"处理过程中发生错误：{str(e)}")
    