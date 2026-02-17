import csv
import re

# Read the slack and time period values from the timing report
with open("../Synthesis/reports/timing.rpt", "r") as report_file:
    report_content = report_file.read()
    slack_match = re.search(r'Slack:=\s*(-?\d+)', report_content)
    slack_value = slack_match.group(1) if slack_match else "0"
    period_match = re.search(r'Clock\s*Edge:\+\s*(\d+)', report_content)
    period_value = period_match.group(1) if period_match else "0"
# Read the combinational area and non-combinational area from area report
with open("../Synthesis/reports/area.rpt", "r") as report_file2:
    report_content2 = report_file2.read()
    comb_match = re.search(r'input_mems\s*\d+\s*\d+\.\d*\s*\d+\.\d*\s*(\d+\.\d*)', report_content2)
    comb_value = comb_match.group(1) if comb_match else "0"
    non_comb_match = re.search(r'input_mems\s*\d+\s*\d+\.\d*\s*\d+\.\d*\s*\d+\.\d*\s*\d+\.\d*\s*\d+\.\d*\s*(\d+\.\d*)', report_content2)
    non_comb_value = non_comb_match.group(1) if non_comb_match else "0"
# Read the static and dynamic power from power report
with open("../Synthesis/reports/power.rpt", "r") as report_file3:
    report_content3 = report_file3.read()
    static_power_match = re.search(r'Subtotal\s*([^ ]+)', report_content3)
    static_power_value = static_power_match.group(1) if static_power_match else "0"
    internal_power_match = re.search(r'Subtotal\s*[^ ]+\s*([^ ]+)', report_content3)
    internal_power_value = internal_power_match.group(1) if internal_power_match else "0"
    switching_power_match = re.search(r'Subtotal\s*[^ ]+\s*[^ ]+\s*([^ ]+)', report_content3)
    switching_power_value = switching_power_match.group(1) if switching_power_match else "0"
    dynamic_power = float(internal_power_value) + float(switching_power_value)


# Define CSV structure
csv_data = [
    ["Extracted Data", " ", "Area", " ", " ", "Power", " ", " ","Timing"],
    [" ", " ", "Combinational Area (um^2)", "Non-combinational Data (um^2)", " ","Static Power (W)","Dynamic Power (W)"," ","Time Period (ps)","Slack (ps)"],
    [" ", " ", comb_value, non_comb_value," ",static_power_value,dynamic_power," ",period_value, slack_value]
]

# Write to new CSV file
with open("Extracted_data.csv", "w", newline="") as csv_file:
    writer = csv.writer(csv_file)
    writer.writerows(csv_data)
