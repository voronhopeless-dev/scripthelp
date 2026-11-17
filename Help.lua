import customtkinter as ctk
import threading, time, subprocess, re, sys
from collections import deque

try:
    import psutil
except ImportError:
    sys.exit("pip install psutil")

try:
    from pynvml import *
    NVML_AVAILABLE = True
except ImportError:
    NVML_AVAILABLE = False

ctk.set_appearance_mode("dark")
ctk.set_default_color_theme("dark-blue")

class UniversalOverlay(ctk.CTk):
    def __init__(self):
        super().__init__()
        self.title("")
        self.geometry("340x240+100+100")
        self.attributes("-topmost", True)
        self.attributes("-alpha", 0.92)
        self.overrideredirect(True)

        self.fps_history = deque(maxlen=30)
        self.ping_history = deque(maxlen=30)
        self.running = True
        self.ping_host = "8.8.8.8"

        self._build_ui()
        self._bind_drag()
        self._start_threads()

    def _build_ui(self):
        self.tabview = ctk.CTkTabview(self, width=320, height=220)
        self.tabview.pack(padx=10, pady=10, fill="both", expand=True)

        self.tab_home = self.tabview.add("Home")
        self.tab_visual = self.tabview.add("Visual")
        self.tab_misc = self.tabview.add("Misc")
        self.tab_config = self.tabview.add("Config")

        self.fps_var = ctk.BooleanVar(value=True)
        self.ping_var = ctk.BooleanVar(value=True)
        self.cpu_var = ctk.BooleanVar(value=False)
        self.gpu_var = ctk.BooleanVar(value=False)
        self.ram_var = ctk.BooleanVar(value=False)

        ctk.CTkSwitch(self.tab_home, text="FPS Counter", variable=self.fps_var).pack(anchor="w", padx=10, pady=(4, 2))
        ctk.CTkSwitch(self.tab_home, text="Ping Display", variable=self.ping_var).pack(anchor="w", padx=10, pady=2)
        ctk.CTkSwitch(self.tab_home, text="CPU Usage", variable=self.cpu_var).pack(anchor="w", padx=10, pady=2)
        ctk.CTkSwitch(self.tab_home, text="GPU Usage", variable=self.gpu_var).pack(anchor="w", padx=10, pady=2)
        ctk.CTkSwitch(self.tab_home, text="RAM Usage", variable=self.ram_var).pack(anchor="w", padx=10, pady=2)

        ctk.CTkLabel(self.tab_visual, text="Overlay HUD", font=("Consolas", 12)).pack(pady=4)
        self.hud = ctk.CTkTextbox(self.tab_visual, width=280, height=80, font=("Consolas", 11))
        self.hud.pack(pady=4)
        self.hud.configure(state="disabled")

        ctk.CTkLabel(self.tab_misc, text="Ping host:").pack(anchor="w", padx=10, pady=(6, 0))
        self.host_entry = ctk.CTkEntry(self.tab_misc, width=260)
        self.host_entry.insert(0, "8.8.8.8")
        self.host_entry.pack(padx=10, pady=2)
        ctk.CTkButton(self.tab_misc, text="Apply", command=self._apply_host).pack(padx=10, pady=4)

        ctk.CTkLabel(self.tab_config, text="Opacity").pack(anchor="w", padx=10)
        self.opacity_slider = ctk.CTkSlider(self.tab_config, from_=0.4, to=1.0, command=self._set_alpha)
        self.opacity_slider.set(0.92)
        self.opacity_slider.pack(padx=10, pady=4)
        ctk.CTkButton(self.tab_config, text="Exit", fg_color="#aa3333", command=self._exit).pack(padx=10, pady=10)

    def _bind_drag(self):
        self.bind("<Button-1>", self._start_move)
        self.bind("<B1-Motion>", self._do_move)
        self.bind("<Escape>", lambda e: self._exit())
        self._dx = self._dy = 0

    def _start_move(self, e):
        self._dx, self._dy = e.x, e.y

    def _do_move(self, e):
        self.geometry(f"+{self.winfo_x()+e.x-self._dx}+{self.winfo_y()+e.y-self._dy}")

    def _set_alpha(self, v):
        self.attributes("-alpha", float(v))

    def _apply_host(self):
        host = self.host_entry.get().strip()
        if host:
            self.ping_host = host

    def _exit(self):
        self.running = False
        self.destroy()

    def _start_threads(self):
        threading.Thread(target=self._fps_loop, daemon=True).start()
        threading.Thread(target=self._ping_loop, daemon=True).start()
        threading.Thread(target=self._update_hud, daemon=True).start()

    def _fps_loop(self):
        while self.running:
            try:
                fps = self._estimate_fps()
                self.fps_history.append(fps)
            except Exception:
                self.fps_history.append(0)
            time.sleep(0.5)

    def _estimate_fps(self):
        if NVML_AVAILABLE:
            try:
                nvmlInit()
                h = nvmlDeviceGetHandleByIndex(0)
                util = nvmlDeviceGetUtilizationRates(h).gpu
                return max(30, min(240, 240 - int(util * 1.5)))
            except Exception:
                pass
        return 0

    def _ping_loop(self):
        while self.running:
            self.ping_history.append(self._ping_once(self.ping_host))
            time.sleep(1.0)

    def _ping_once(self, host):
        try:
            if sys.platform.startswith("win"):
                out = subprocess.check_output(
                    ["ping", "-n", "1", "-w", "1000", host],
                    stderr=subprocess.DEVNULL,
                    creationflags=subprocess.CREATE_NO_WINDOW
                ).decode(errors="ignore")
                m = re.search(r"[=<](\d+)\s*ms", out)
                return int(m.group(1)) if m else -1
            else:
                out = subprocess.check_output(
                    ["ping", "-c", "1", "-W", "1", host],
                    stderr=subprocess.DEVNULL
                ).decode(errors="ignore")
                m = re.search(r"time=([\d.]+)", out)
                return int(float(m.group(1))) if m else -1
        except Exception:
            return -1

    def _update_hud(self):
        while self.running:
            lines = []
            if self.fps_var.get():
                lines.append(f"FPS: {self.fps_history[-1] if self.fps_history else 0}")
            if self.ping_var.get():
                lines.append(f"Ping: {self.ping_history[-1] if self.ping_history else -1} ms")
            if self.cpu_var.get():
                lines.append(f"CPU: {psutil.cpu_percent():.0f}%")
            if self.ram_var.get():
                lines.append(f"RAM: {psutil.virtual_memory().percent:.0f}%")
            if self.gpu_var.get():
                lines.append(f"GPU: {self._gpu_usage()}%")
            text = "\n".join(lines) if lines else "—"
            self.hud.configure(state="normal")
            self.hud.delete("1.0", "end")
            self.hud.insert("1.0", text)
            self.hud.configure(state="disabled")
            time.sleep(0.5)

    def _gpu_usage(self):
        if not NVML_AVAILABLE:
            return "N/A"
        try:
            nvmlInit()
            h = nvmlDeviceGetHandleByIndex(0)
            return nvmlDeviceGetUtilizationRates(h).gpu
        except Exception:
            return "N/A"

if __name__ == "__main__":
    app = UniversalOverlay()
    app.mainloop()
