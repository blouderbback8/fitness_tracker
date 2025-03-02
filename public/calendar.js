document.addEventListener("DOMContentLoaded", () => {
  const workouts = document.querySelectorAll(".workout, .indulgence");
  const calendarDays = document.querySelectorAll(".calendar-day");

  workouts.forEach(workout => {
    workout.addEventListener("dragstart", (event) => {
      event.dataTransfer.setData("text/plain", event.target.dataset.id);
      event.dataTransfer.setData("type", event.target.classList.contains("workout") ? "workout" : "indulgence");
    });
  });

  calendarDays.forEach(day => {
    day.addEventListener("dragover", (event) => {
      event.preventDefault();
    });

    day.addEventListener("drop", (event) => {
      event.preventDefault();
      const itemId = event.dataTransfer.getData("text/plain");
      const itemType = event.dataTransfer.getData("type");
      const newDate = day.dataset.date;

      fetch(`/update_date`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json"
        },
        body: JSON.stringify({ id: itemId, type: itemType, date: newDate })
      }).then(() => {
        location.reload();
      });
    });
  });

  // Auto-refresh after adding an indulgence
  const indulgenceForm = document.querySelector('form[action="/add_indulgence"]');
  if (indulgenceForm) {
    indulgenceForm.addEventListener("submit", () => {
      setTimeout(() => {
        location.reload();
      }, 500);
    });
  }
});
