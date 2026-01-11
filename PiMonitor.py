import tkinter as tk
import psutil
import subprocess
import platform
from collections import deque
import time

# ----------------------------
# Raspberry Pi Functions
# ----------------------------
def get_cpu_temp():
    try:
        out = subprocess.check_output(['vcgencmd', 'measure_temp']).decode()
        return float(out.split('=')[1].split("'")[0])
    except:
        return 0.0

def get_cpu_clock():
    try:
        out = subprocess.check_output(['vcgencmd', 'measure_clock', 'arm']).decode()
        return round(int(out.split('=')[1]) / 1_000_000, 1)
    except:
        return 0.0

# ----------------------------
# GUI Setup
# ----------------------------
root = tk.Tk()
root.title("Pi Monitor")
ui_width = 340
ui_height = 360
root.geometry(f"{ui_width}x{ui_height}")
root.configure(bg="#f2f2f2")

font_title = ("Segoe UI", 12, "bold")
font_main = ("Segoe UI", 9)
pi_red = "#cc0000"
text_dark = "#222222"

def panel(parent, height=20):
    f = tk.Frame(parent, bg="#ffffff", bd=1, relief="solid", height=height)
    f.pack(fill="x", padx=4, pady=1)
    return f

# ----------------------------
# Pages
# ----------------------------
page_pi = tk.Frame(root, bg="#f2f2f2")
page_pc = tk.Frame(root, bg="#f2f2f2")
page_dev = tk.Frame(root, bg="#f2f2f2")
pages = [page_pi, page_pc, page_dev]
current_page = 0

def show_page(idx):
    global current_page
    pages[current_page].place_forget()
    pages[idx].place(x=0, y=30, width=ui_width, height=ui_height-30)
    current_page = idx

# ----------------------------
# Navigation Buttons
# ----------------------------
btn_frame = tk.Frame(root, bg="#f2f2f2")
btn_frame.place(x=0, y=0, width=ui_width, height=30)

def nav_btn(text, idx):
    return tk.Button(btn_frame, text=text, bg="#ffffff", fg=text_dark,
                     font=("Segoe UI", 9), width=11, command=lambda: show_page(idx))

nav_btn("Raspberry Pi", 0).pack(side="left", padx=2, pady=2)
nav_btn("System Info", 1).pack(side="left", padx=2, pady=2)
nav_btn("Developer", 2).pack(side="left", padx=2, pady=2)

# ----------------------------
# Raspberry Pi Page
# ----------------------------
tk.Label(page_pi, text="Raspberry Pi Monitor",
         font=font_title, fg=pi_red, bg="#f2f2f2").pack(pady=1)

p_temp = panel(page_pi)
p_usage = panel(page_pi)
p_clock = panel(page_pi)
p_ram = panel(page_pi)
p_disk = panel(page_pi)

l_temp = tk.Label(p_temp, font=font_main, bg="#fff", anchor="w")
l_usage = tk.Label(p_usage, font=font_main, bg="#fff", anchor="w")
l_clock = tk.Label(p_clock, font=font_main, bg="#fff", anchor="w")
l_ram = tk.Label(p_ram, font=font_main, bg="#fff", anchor="w")
l_disk = tk.Label(p_disk, font=font_main, bg="#fff", anchor="w")

for lbl in [l_temp, l_usage, l_clock, l_ram, l_disk]:
    lbl.pack(fill="x", padx=4)

# ----------------------------
# CPU Temperature Graph
# ----------------------------
graph_panel = tk.Frame(page_pi, bg="#ffffff", bd=1, relief="solid")
graph_panel.pack(fill="x", padx=4, pady=2, expand=True)
tk.Label(graph_panel, text="CPU Temperature Graph",
         font=font_main, fg=pi_red, bg="#ffffff").pack()

canvas_width = 300
canvas_height = 100
graph_canvas = tk.Canvas(graph_panel, width=canvas_width, height=canvas_height,
                         bg="#fafafa", highlightthickness=0)
graph_canvas.pack()

history = deque([40]*40, maxlen=40)

def draw_graph():
    graph_canvas.delete("all")
    # Side scale fully visible 0-100
    for i in range(0, 101, 10):
        y = canvas_height - (i/100)*canvas_height
        graph_canvas.create_line(0, y, 15, y, fill="#000")
        graph_canvas.create_text(18, y, text=str(i), anchor="w", font=("Segoe UI", 7))
    # Graph lines
    for i in range(1, len(history)):
        x1 = 20 + (i-1)*(canvas_width-30)/(len(history)-1)
        x2 = 20 + i*(canvas_width-30)/(len(history)-1)
        y1 = canvas_height - (history[i-1]/100)*canvas_height
        y2 = canvas_height - (history[i]/100)*canvas_height
        r = min(255,int(history[i]*2.55))
        color = f"#{r:02x}0000"
        graph_canvas.create_line(x1, y1, x2, y2, fill=color, width=2)

# ----------------------------
# PC Info Page
# ----------------------------
tk.Label(page_pc, text="System Information",
         font=font_title, fg=pi_red, bg="#f2f2f2").pack(pady=1)

pc_panels = {}
for key in ["CPU Model", "Cores", "Frequency", "RAM", "Disk", "OS"]:
    p = panel(page_pc)
    lbl = tk.Label(p, font=font_main, bg="#fff", anchor="w")
    lbl.pack(fill="x", padx=4)
    pc_panels[key] = lbl

# FPS Graph (PC page)
fps_panel = tk.Frame(page_pc, bg="#ffffff", bd=1, relief="solid")
fps_panel.pack(fill="x", padx=4, pady=2, expand=True)
tk.Label(fps_panel, text="FPS Graph",
         font=font_main, fg=pi_red, bg="#ffffff").pack()
fps_canvas = tk.Canvas(fps_panel, width=canvas_width, height=canvas_height,
                       bg="#fafafa", highlightthickness=0)
fps_canvas.pack()
fps_history = deque([60]*40, maxlen=40)  # start FPS at 60

def draw_fps_graph():
    fps_canvas.delete("all")
    for i in range(0, 101, 10):
        y = canvas_height - (i/100)*canvas_height
        fps_canvas.create_line(0, y, 15, y, fill="#000")
        fps_canvas.create_text(18, y, text=str(i), anchor="w", font=("Segoe UI", 7))
    for i in range(1, len(fps_history)):
        x1 = 20 + (i-1)*(canvas_width-30)/(len(fps_history)-1)
        x2 = 20 + i*(canvas_width-30)/(len(fps_history)-1)
        y1 = canvas_height - (fps_history[i-1]/100)*canvas_height
        y2 = canvas_height - (fps_history[i]/100)*canvas_height
        g = min(255,int(fps_history[i]*2.55))
        color = f"#00{g:02x}00"
        fps_canvas.create_line(x1, y1, x2, y2, fill=color, width=2)

# ----------------------------
# Developer Page
# ----------------------------
tk.Label(page_dev, text="Developer Info",
         font=font_title, fg=pi_red, bg="#f2f2f2").pack(pady=1)
l_dev = tk.Label(page_dev, font=font_main, bg="#f2f2f2", justify="left", wraplength=320,
                 text="Pi Monitor GUI v1.24\n\n"
                      "Usage:\n"
                      "- Use top buttons to switch pages.\n"
                      "- Raspberry Pi page shows CPU temperature, load and graph.\n"
                      "- System Info lists hardware and OS details.\n\n"
                      "Developer Info:\n"
                      "- Application created by D4rk.\n"
                      "- Join our Discord server: https://discord.gg/rjDeyCkMdS\n"
                      "- Follow on Youtube: abel3189\n"
                      "- Follow on Pinterest: belkomromy\n"
                      "- GUI is still in beta\n"
                      "- Please report bugs on my discord server\n"
                      "- Thank you for useing PI monitor\n"
                      "- NOT offical application!\n")
l_dev.pack(padx=4, pady=2, anchor="w")

# ----------------------------
# FPS Measurement and Update
# ----------------------------
frame_times = deque(maxlen=30)
last_update_values = 0
last_frame_time = time.time()

def update():
    global last_update_values, last_frame_time
    now = time.time()
    delta = now - last_frame_time
    last_frame_time = now

    # ---- Raspberry Pi Graph
    temp = get_cpu_temp()
    history.append(temp)
    draw_graph()

    # ---- FPS
    if delta > 0:
        fps = 1/delta
    else:
        fps = 0
    fps_history.append(min(fps, 100))
    draw_fps_graph()

    # ---- Slow text updates every 0.5s
    if now - last_update_values > 0.5:
        last_update_values = now
        usage = psutil.cpu_percent()
        clock = get_cpu_clock()
        ram = psutil.virtual_memory()
        disk = psutil.disk_usage('/')
        l_temp.config(text=f"Temp: {temp:.1f} °C")
        l_usage.config(text=f"CPU Usage: {usage:.0f}%")
        l_clock.config(text=f"Clock: {clock} MHz")
        l_ram.config(text=f"RAM: {ram.used//1048576}/{ram.total//1048576} MB")
        l_disk.config(text=f"Disk: {disk.used/1e9:.1f}/{disk.total/1e9:.1f} GB")
        # PC Info
        pc_panels["CPU Model"].config(text=f"CPU: {platform.processor()}")
        pc_panels["Cores"].config(text=f"Cores: {psutil.cpu_count(True)}")
        freq = psutil.cpu_freq()
        pc_panels["Frequency"].config(text=f"Freq: {freq.current:.0f} MHz" if freq else "Freq: n/a")
        pc_panels["RAM"].config(text=f"RAM: {ram.total//1048576} MB")
        pc_panels["Disk"].config(text=f"Disk: {disk.total/1e9:.1f} GB")
        pc_panels["OS"].config(text=f"OS: {platform.system()} {platform.release()}")

    root.after(20, update)

# ----------------------------
# Start GUI
# ----------------------------
page_pi.place(x=0, y=30, width=ui_width, height=ui_height-30)
update()
root.mainloop()
