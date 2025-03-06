document.addEventListener("DOMContentLoaded", () => {
  const workouts = document.querySelectorAll(".workout, .indulgence");
  const calendarDays = document.querySelectorAll(".calendar-day");
  const indulgenceForm = document.getElementById("indulgence-form");
  const indulgenceInput = document.getElementById("indulgence-name");
  const indulgenceDateInput = document.getElementById("indulgence-date");
  const submitButton = document.getElementById("indulgence-submit");
  const notifications = document.getElementById("notifications");

  // Function to show pop-up alerts
  function showAlert(message) {
      alert(message);
  }

  // Function to display on-screen notifications
  function showNotification(message) {
      const notification = document.createElement("div");
      notification.className = "notification";
      notification.innerText = message;
      notifications.appendChild(notification);
      setTimeout(() => {
          notification.remove();
      }, 5000);
  }

  // Prevent alcohol logging on the day before Jiu-Jitsu (Sunday, Tuesday, Thursday)
  indulgenceDateInput.addEventListener("change", () => {
      const selectedDate = new Date(indulgenceDateInput.value);
      const day = selectedDate.toLocaleString('en-us', { weekday: 'long' }).toLowerCase();
      
      if (["sunday", "tuesday", "thursday"].includes(day) && indulgenceInput.value.toLowerCase().includes("alcohol")) {
          showAlert("🚫 Alcohol cannot be logged today because tomorrow is a Jiu-Jitsu day.");
          submitButton.disabled = true;
      } else {
          submitButton.disabled = false;
      }
  });

  // Auto-refresh after adding an indulgence
  if (indulgenceForm) {
      indulgenceForm.addEventListener("submit", () => {
          setTimeout(() => {
              location.reload();
          }, 500);
      });
  }
});
