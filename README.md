Esta es la pantalla individual de los graficos, falta una mejora visual y migrarlo a NotWaste, por el resto recibe y muestra los datos perfectamente. Adjunto las funciones y url agregadas a la api por si lo quieres probar.

## views.py

from .models import Food
from django.http import JsonResponse
from django.db.models import Count, Sum
from datetime import date, timedelta, datetime
from dateutil.relativedelta import relativedelta
from django.db.models.functions import ExtractMonth, ExtractDay

### Resumen semanal
def get_weekly_summary(request):
    today = date.today()
    week_start = today - timedelta(days=today.weekday())
    week_end = week_start + timedelta(days=6)

    foods = Food.objects.filter(food_state=1, discard_date__range=[week_start, week_end])
    food_amounts = foods.values('discard_date').annotate(total_amount=Sum('food_amount_g')).order_by('discard_date')

    weekly_summary = [0] * 7
    for food_amount in food_amounts:
        day_of_week = (food_amount['discard_date'] - week_start).days
        weekly_summary[day_of_week] = food_amount['total_amount']

    return JsonResponse({'summary': weekly_summary})

### Resumen de los últimos 3 meses con datos diarios
def get_monthly_summary(request):
    today = date.today()
    three_months_ago = today - timedelta(days=90)

    foods = Food.objects.filter(food_state=1, discard_date__range=[three_months_ago, today])
    food_amounts = foods.annotate(month=ExtractMonth('discard_date'), day=ExtractDay('discard_date')).values('month', 'day').annotate(total_amount=Sum('food_amount_g')).order_by('month', 'day')

    # Crear una estructura de datos para los últimos 3 meses con el mes, día y el total de alimentos
    monthly_summary = []
    for food_amount in food_amounts:
        monthly_summary.append({
            'month': food_amount['month'],
            'day': food_amount['day'],
            'total_amount': food_amount['total_amount']
        })

    return JsonResponse({'monthly_summary': monthly_summary})

### Resumen de los últimos 12 meses con mes incluido
def get_yearly_summary(request):
    today = date.today()
    year_start = (today.replace(day=1) - timedelta(days=365)).replace(day=1)
    year_end = today

    foods = Food.objects.filter(food_state=1, discard_date__range=[year_start, year_end])
    food_amounts = foods.annotate(month=ExtractMonth('discard_date')).values('month').annotate(total_amount=Sum('food_amount_g')).order_by('month')

    # Crear un diccionario para los últimos 12 meses con el mes y el total de alimentos
    yearly_summary = []
    for food_amount in food_amounts:
        yearly_summary.append({
            'month': food_amount['month'],
            'total_amount': food_amount['total_amount']
        })

    return JsonResponse({'yearly_summary': yearly_summary})

### Resumen semanal
def get_weekly_summary_price(request):
    today = date.today()
    week_start = today - timedelta(days=today.weekday())
    week_end = week_start + timedelta(days=6)

    foods = Food.objects.filter(food_state=1, discard_date__range=[week_start, week_end])
    food_amounts = foods.values('discard_date').annotate(total_amount=Sum('food_price')).order_by('discard_date')

    weekly_summary_price = [0] * 7
    for food_amount in food_amounts:
        day_of_week = (food_amount['discard_date'] - week_start).days
        weekly_summary_price[day_of_week] = food_amount['total_amount']

    return JsonResponse({'summary_price': weekly_summary_price})

### Resumen de los últimos 3 meses con datos diarios
def get_monthly_summary_price(request):
    today = date.today()
    three_months_ago = today - timedelta(days=90)

    foods = Food.objects.filter(food_state=1, discard_date__range=[three_months_ago, today])
    food_amounts = foods.annotate(month=ExtractMonth('discard_date'), day=ExtractDay('discard_date')).values('month', 'day').annotate(total_amount=Sum('food_price')).order_by('month', 'day')

    # Crear una estructura de datos para los últimos 3 meses con el mes, día y el total de alimentos
    monthly_summary_price = []
    for food_amount in food_amounts:
        monthly_summary_price.append({
            'month': food_amount['month'],
            'day': food_amount['day'],
            'total_amount': food_amount['total_amount']
        })

    return JsonResponse({'monthly_summary_price': monthly_summary_price})

### Resumen de los últimos 12 meses con mes incluido
def get_yearly_summary_price(request):
    today = date.today()
    year_start = (today.replace(day=1) - timedelta(days=365)).replace(day=1)
    year_end = today

    foods = Food.objects.filter(food_state=1, discard_date__range=[year_start, year_end])
    food_amounts = foods.annotate(month=ExtractMonth('discard_date')).values('month').annotate(total_amount=Sum('food_price')).order_by('month')

    # Crear un diccionario para los últimos 12 meses con el mes y el total de alimentos
    yearly_summary_price = []
    for food_amount in food_amounts:
        yearly_summary_price.append({
            'month': food_amount['month'],
            'total_amount': food_amount['total_amount']
        })

    return JsonResponse({'yearly_summary_price': yearly_summary_price})


## urls.py

from django.urls import path
from . import views

urlpatterns = [
    path('api/weekly_summary/', views.get_weekly_summary, name='weekly_summary'),
    path('api/monthly_summary/', views.get_monthly_summary, name='monthly_summary'),
    path('api/yearly_summary/', views.get_yearly_summary, name='yearly_summary'),
    path('api/weekly_summary_price/', views.get_weekly_summary_price, name='weekly_summary_price'),
    path('api/monthly_summary_price/', views.get_monthly_summary_price, name='monthly_summary_price'),
    path('api/yearly_summary_price/', views.get_yearly_summary_price, name='yearly_summary_price'),
]
