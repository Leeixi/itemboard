from django import forms
from .models import Item

class NewItemForm(forms.ModelForm):
    class Meta:
        model = Item
        fields = ('category', 'name', 'description', 'image', 'created_by')
        widgets = {
            'name': forms.TextInput(attrs={
                'placeholder': 'Enter item name.',
                'class': "w-full py-4 px-6 rounded-xl"
            }),
            'description': forms.Textarea(attrs={
                'placeholder': 'Enter description of item.',
                'class': "w-full py-4 px-6 rounded-xl"
            })
        }
