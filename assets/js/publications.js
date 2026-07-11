(() => {
  const filters = Array.from(document.querySelectorAll("[data-publication-filter]"));
  const cards = Array.from(document.querySelectorAll("[data-publication-categories]"));

  if (filters.length === 0 || cards.length === 0) {
    return;
  }

  const applyFilter = (category) => {
    cards.forEach((card) => {
      const categories = (card.dataset.publicationCategories || "").split(/\s+/);
      card.hidden = category !== "all" && !categories.includes(category);
    });

    filters.forEach((filter) => {
      const isActive = filter.dataset.publicationFilter === category;
      filter.classList.toggle("is-active", isActive);
      filter.setAttribute("aria-pressed", String(isActive));
    });
  };

  filters.forEach((filter) => {
    filter.addEventListener("click", () => {
      applyFilter(filter.dataset.publicationFilter || "all");
    });
  });
})();
