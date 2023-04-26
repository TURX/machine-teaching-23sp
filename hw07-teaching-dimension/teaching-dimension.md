---
title: "Teaching Dimension"
subtitle: "Homework 7, Machine Teaching WISCERS, 2023 Spring"
author: |
  Ruixuan Tu \
  \small ruixuan@cs.wisc.edu \
  \small University of Wisconsin--Madison
date: \UKvardate \today
documentclass: article
classoption: 12pt, letterpaper
geometry: margin=1in
pandoc_args: ["--mathjax"]
output:
  pdf_document:
    latex_engine: xelatex
    includes:
        in_header: /Users/turx/Apps/pandoc/math-preamble.tex
    standalone: true
---

# Definition

$\operatorname{TD}(C)=\max_{c\in C}\left( \min_{\tau\in T(c)} \left\vert \tau \right\vert  \right)$

# Problem 2

By problem setting, $C=\left\{ c_{ab} : 1\leq a\leq b\leq n \right\}$, we could calculate the cardinality $\left\vert C \right\vert = \sum_{a=1}^{n-1}\sum_{b=a}^{n} 1 = n^2-n$.

For an teaching instance $c_{ab}$, we can see we need at least $T(c_{ab}) = \left\{ a, b \right\}$ to specify it. By this specification, with the setting $x_i=i$ for all $i\in \left[ 1, n \right] \cup \mathbb{Z}$, we can interpret a teaching set $T(c_{ab})$ as the rule $\operatorname{sgn}(x_i)=\begin{cases}
  + & \text{if } i\in \left[ a, b \right] \\
  - & \text{otherwise}
\end{cases}$. The max cardinality $\max \left\vert T(c_{ab}) \right\vert = 2$ for all $a, b$. Therefore, $\operatorname{TD}(C)=2$. $\square$

In case that $C=\left\{ c_{ab} \right\}$ with $a, b$ be constants, as there is only one teaching instance, we do not need to distinguish it from other instances, so $T(c_{ab})=0$ and $\operatorname{TD}(C)=0$.

The $T(c_{ab})$ above is the maximum situation for the original $C$, because we could use only $a=n-1$ to specify $c_{n-1,n}$ and only $b=2$ to specify $c_{1,2}$, in which case $T(c_{ab})=1$.

# Problem 3

By problem setting, $C=\left\{ c_{ab}, \bar{c}_{ab} : 1\leq a\leq b\leq n \right\}$. For an teaching instance $c_{ab}$, we can see we need at least $T(c_{ab}) = \left\{ a, b, p \right\}$ where $p=+$ to specify it, because we need to distinct the complement case: for $\bar{c}_{ab}$, $T(\bar{c}_{ab})=\left\{ a, b, p \right\}$ where $p=-$. By this specification, with the setting $x_i=i$ for all $i\in \left[ 1, n \right] \cup \mathbb{Z}$ and the notation $c'_{abp}$ defined by $c'_{ab+}=c_{ab}$ and $c'_{ab-}=\bar{c}_{ab}$, we can interpret a teaching set $T(c'_{abp})$ as the rule $\operatorname{sgn}(x_i)=\begin{cases}
  + \cdot p & \text{if } i\in \left[ a, b \right] \\
  - \cdot p & \text{if } i\in \left[ a, b \right]
\end{cases}$. The max cardinality $\max \left\vert T(c_{ab}) \right\vert = 3$ for all $a, b$. Therefore, $\operatorname{TD}(C)=3$. $\square$

If we remove one case (either $c_{ab}$ or $\bar{c}_{ab}$ from $C$), we do not need $p$ to distinguish instances, so we reduce this setting to Problem 2.
