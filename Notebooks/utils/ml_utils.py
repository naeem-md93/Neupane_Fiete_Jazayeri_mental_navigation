from scipy import stats


class FitResult:
    def __init__(self, slope, intercept, adj_r_squared):
        self.Coefficients = type('obj', (object,), {'Estimate': [intercept, slope]})
        self.Rsquared = type('obj', (object,), {'Adjusted': adj_r_squared})


def fitlm(x, y):
    """Helper to mimic Matlab's fitlm for simple linear regression."""
    slope, intercept, r_value, p_value, std_err = stats.linregress(x, y)
    # Adjusted R-squared calculation
    n = len(x)
    adj_r_squared = 1 - (1 - r_value ** 2) * (n - 1) / (n - 2) if n > 2 else 0

    return FitResult(slope, intercept, adj_r_squared)
