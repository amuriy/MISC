import tkinter as tk
import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits import mplot3d


fields = ('X', 'Y', 'Z', 'sigma', 'rho', 'beta')

def lorenz(x, y, z, s, r, b):
    x_dot = s*(y - x)
    y_dot = r*x - y - x*z
    z_dot = x*y - b*z
    return x_dot, y_dot, z_dot


def plot(entries):

    x = float(entries['X'].get())
    y = float(entries['Y'].get())
    z = float(entries['Z'].get())
    s = float(entries['sigma'].get())
    r = float(entries['rho'].get())
    b = float(entries['beta'].get())
    
    dt = 0.01
    num_steps = 10000

    # Need one more for the initial values
    xs = np.empty(num_steps + 1)
    ys = np.empty(num_steps + 1)
    zs = np.empty(num_steps + 1)
    
    # Set initial values
    xs[0], ys[0], zs[0] = (0., 1., 1.05)

    # Step through "time", calculating the partial derivatives at the current point
    # and using them to estimate the next point
    for i in range(num_steps):
        x_dot, y_dot, z_dot = lorenz(xs[i], ys[i], zs[i], s, r, b)
        xs[i + 1] = xs[i] + (x_dot * dt)
        ys[i + 1] = ys[i] + (y_dot * dt)
        zs[i + 1] = zs[i] + (z_dot * dt)
        
    # Plot
    fig = plt.figure()
    ax = fig.gca(projection='3d')
    
    ax.plot(xs, ys, zs, lw=0.5)
    ax.set_xlabel("X")
    ax.set_ylabel("Y")
    ax.set_zlabel("Z")
    ax.set_title("Аттрактор Лоренца")
    
    plt.show()


def makeform(root, fields):
    entries = {}
    for field in fields:
        row = tk.Frame(root)
        lab = tk.Label(row, width=22, text=field+": ", anchor='w')
        ent = tk.Entry(row)
        ent.insert(0, "0")
        row.pack(side=tk.TOP, 
                 fill=tk.X, 
                 padx=5, 
                 pady=5)
        lab.pack(side=tk.LEFT)
        ent.pack(side=tk.RIGHT, 
                 expand=tk.YES, 
                 fill=tk.X)
        entries[field] = ent
    return entries


if __name__ == '__main__':
    root = tk.Tk()
    ents = makeform(root, fields)
    
    b1 = tk.Button(root, text='Рассчитать',
                   command=(lambda e=ents: plot(e)))
    b1.pack(side=tk.LEFT, padx=5, pady=5)
    b2 = tk.Button(root, text='Выйти', command=root.quit)
    b2.pack(side=tk.LEFT, padx=5, pady=5)
    root.mainloop()
    
