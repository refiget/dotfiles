# %%
print("Molten is alive 🚀")

# %%
import numpy as np

x = np.linspace(0, 2 * np.pi, 100)
y = np.sin(x)

print("sin(x) computed, first 5 values:")
print(y[:5])

# %%
import matplotlib.pyplot as plt

plt.figure(figsize=(6, 4))
plt.plot(x, y, label="sin(x)")
plt.title("Molten test plot")
plt.xlabel("x")
plt.ylabel("sin(x)")
plt.legend()
plt.tight_layout()
plt.show()

# %%
try:
    1 / 0
except Exception as e:
    print("Caught error:", e)

print("If you saw text + a plot above, Molten works ✅")
# %%

