__all__ = ['solver_uart_console', 'solver_host']

import os
import sys

if os.path.join(os.path.dirname(__file__), '..') not in sys.path:
    sys.path.append(os.path.join(os.path.dirname(__file__), '..'))

import solver_uart_console
import solver_host
