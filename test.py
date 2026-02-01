# %%
# Basic sanity test: Python + stdout
print("Molten is alive 🚀")

# %%
# Numeric computation
import numpy as np

x = np.linspace(0, 2 * np.pi, 100)
y = np.sin(x)

print("sin(x) computed, first 5 values:")
print(y[:5])

# %%
# Plot test (image output)
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
# Error handling test (should show traceback nicely)
try:
    1 / 0
except Exception as e:
    print("Caught error:", e)

# %%
# Final message
print("If you saw text + a plot above, Molten works ✅")
